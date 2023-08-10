
import XCTest
import MoviesDBCore

protocol MoviesStore {
    func deleteCachedMovies(completion: @escaping (Error?) -> Void)
    func insert(_ movies: [Movie], completion: @escaping (Error?) -> Void)
}

final class LocalMoviesLoader {
    
    private let store: MoviesStore
    
    init(store: MoviesStore) {
        self.store = store
    }
    
    func save(_ movies: [Movie], completion: @escaping (Error?) -> Void) {
        store.deleteCachedMovies { [weak self] error in
            if error == nil {
                self?.store.insert(movies) { error in
                  completion(error)
                }
            } else {
                completion(error)
            }
        }
    }
}

final class CacheMoviesUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageCacheUponCreation() {
        let store = makeSUT().store
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    func test_save_requestsCacheDeletion() {
        let (store, sut) = makeSUT()
        
        sut.save(makeMovies()) { _ in }
        
        XCTAssertEqual(store.messages, [.deleteCachedMovies])
    }
    
    func test_save_doesNotRequestInsertionOnCacheDeletionError() {
        let deletionError = NSError(domain: "deletion error", code: 0)
        let (store, sut) = makeSUT()
        
        sut.save(makeMovies()) { _ in }
        
        store.completeDeletion(with: deletionError)
        XCTAssertEqual(store.messages, [.deleteCachedMovies])
    }
    
    func test_save_requestsNewCacheInsertionOnSuccessfulDeletion() {
        let movies = makeMovies()
        let (store, sut) = makeSUT()
        
        sut.save(movies) { _ in }
        
        store.completeDeletionSuccessfully()
        XCTAssertEqual(store.messages, [.deleteCachedMovies, .insert(movies)])
    }
    
    func test_save_failsOnDeletionError() {
        let deletionError = NSError(domain: "deletion error", code: 0)
        let (store, sut) = makeSUT()
        
        let exp = expectation(description: "wait for save")
        sut.save(makeMovies()) { error in
            XCTAssertEqual(deletionError, error as? NSError)
            exp.fulfill()
        }
        
        store.completeDeletion(with: deletionError)
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_save_succeedsOnSuccessfulCacheInsertion() {
        let (store, sut) = makeSUT()
        let movies = makeMovies()
        
        let exp = expectation(description: "wait for save")
        sut.save(movies) { error in
            XCTAssertNil(error)
            exp.fulfill()
        }
        
        store.completeDeletionSuccessfully()
        store.completeInsertionSuccessfully()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_save_failsOnCacheInsertionError() {
        let insertionError = NSError(domain: "insertion error", code: 0)
        let (store, sut) = makeSUT()
        
        let exp = expectation(description: "Wait for save")
        sut.save(makeMovies()) { error in
            XCTAssertEqual(insertionError, error as? NSError)
            exp.fulfill()
        }
        
        store.completeDeletionSuccessfully()
        store.completeInsertion(with: insertionError)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (store: MoviesStoreSpy, sut: LocalMoviesLoader) {
        let store = MoviesStoreSpy()
        let sut = LocalMoviesLoader(store: store)
        trackMemoryLeaks(store, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        
        return (store, sut)
    }
    
    final class MoviesStoreSpy: MoviesStore {
        private(set) var messages = [Message]()
        private var deletionCompletions = [(Error?) -> Void]()
        private var insertionCompletions = [(Error?) -> Void]()
        
        enum Message: Equatable {
            case deleteCachedMovies
            case insert([Movie])
        }
        
        func deleteCachedMovies(completion: @escaping (Error?) -> Void) {
            messages.append(.deleteCachedMovies)
            deletionCompletions.append(completion)
        }
        
        func insert(_ movies: [Movie], completion: @escaping (Error?) -> Void) {
            messages.append(.insert(movies))
            insertionCompletions.append(completion)
        }
        
        func completeDeletion(with error: Error, at index: Int = 0) {
            deletionCompletions[index](error)
        }
        
        func completeDeletionSuccessfully(at index: Int = 0) {
            deletionCompletions[index](.none)
        }
        
        func completeInsertionSuccessfully(at index: Int = 0) {
            insertionCompletions[index](.none)
        }
        
        func completeInsertion(with error: Error, at index: Int = 0) {
            insertionCompletions[index](error)
        }
    }
    
    func makeMovies() -> [Movie] {
        let movie1 = Movie(
            id: 1,
            title: "title1",
            overview: "overview1",
            releaseDate: Date(timeIntervalSince1970: 1627430400),
            posterImageURL: URL(string: "http://poster-image-base-url.com/w0cn9vwzkheuCT2a2MStdnadOyh.jpg")!
        )
        
        let movie2 = Movie(
            id: 2,
            title: "title2",
            overview: "overview2",
            releaseDate: Date(timeIntervalSince1970: 970617600),
            posterImageURL: URL(string: "http://poster-image-base-url.com/9vwzkheuCT2MStdnadOyh.jpg")!
        )
        
        let movie3 = Movie(
            id: 3,
            title: "title3",
            overview: "overview3",
            releaseDate: Date(timeIntervalSince1970: 1111276800),
            posterImageURL: URL(string: "http://poster-image-base-url.com/9vwzkheuCT2a2MStdnadOyh.jpg")!
        )
        
        return [movie1, movie2, movie3]
    }
}
