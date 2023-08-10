
import XCTest
import MoviesDBCore

protocol MoviesStore {
    func deleteCachedMovies(completion: @escaping (Error?) -> Void)
    func insert(_ movies: [Movie])
}

final class LocalMoviesLoader {
    
    private let store: MoviesStore
    
    init(store: MoviesStore) {
        self.store = store
    }
    
    func save(_ movies: [Movie]) {
        store.deleteCachedMovies { [weak self] error in
            if error == nil {
                self?.store.insert(movies)
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
        
        sut.save(makeMovies())
        
        XCTAssertEqual(store.messages, [.deleteCachedMovies])
    }
    
    func test_save_doesNotRequestInsertionOnCacheDeletionError() {
        let deletionError = NSError(domain: "deletion error", code: 0)
        let (store, sut) = makeSUT()
        
        sut.save(makeMovies())
        
        store.completeDeletion(with: deletionError)
        XCTAssertEqual(store.messages, [.deleteCachedMovies])
    }
    
    func test_save_requestsNewCacheInsertionOnSuccessfulDeletion() {
        let movies = makeMovies()
        let (store, sut) = makeSUT()
        
        sut.save(movies)
        
        store.completeDeletionSuccessfully()
        XCTAssertEqual(store.messages, [.deleteCachedMovies, .insert(movies)])
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
        
        enum Message: Equatable {
            case deleteCachedMovies
            case insert([Movie])
        }
        
        func deleteCachedMovies(completion: @escaping (Error?) -> Void) {
            messages.append(.deleteCachedMovies)
            deletionCompletions.append(completion)
        }
        
        func insert(_ movies: [Movie]) {
            messages.append(.insert(movies))
        }
        
        func completeDeletion(with error: Error, at index: Int = 0) {
            deletionCompletions[index](error)
        }
        
        func completeDeletionSuccessfully(at index: Int = 0) {
            deletionCompletions[index](.none)
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
