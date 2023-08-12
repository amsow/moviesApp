
import XCTest
import MoviesDBCore

protocol MoviesStore {
    typealias DeletionResult = Result<Void, Error>
    typealias InsertionResult = Result<Void, Error>
    
    typealias DeletionCompletion = (DeletionResult) -> Void
    typealias InsertionCompletion = (InsertionResult) -> Void
    
    func deleteCachedMovies(completion: @escaping DeletionCompletion)
    func insert(_ movies: [Movie], completion: @escaping InsertionCompletion)
}

final class LocalMoviesLoader {
    typealias SaveResult = Result<Void, Error>
    
    private let store: MoviesStore
    
    init(store: MoviesStore) {
        self.store = store
    }
    
    func save(_ movies: [Movie], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedMovies { [weak self] deletionResult in
            guard let self = self else { return }
            switch deletionResult {
            case .success:
                self.cache(movies, with: completion)
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func cache(_ movies: [Movie], with completion: @escaping (SaveResult) -> Void) {
        self.store.insert(movies) { [weak self] insertionResult in
            guard self != nil else { return }
            if case .failure(let error) = insertionResult {
                completion(.failure(error))
            } else {
                completion(insertionResult)
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
        
        expect(sut, toCompleteWith: deletionError, when: {
            store.completeDeletion(with: deletionError)
        })
    }
    
    func test_save_succeedsOnSuccessfulCacheInsertion() {
        let (store, sut) = makeSUT()
        
        expect(sut, toCompleteWith: nil, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        })
    }
    
    func test_save_failsOnCacheInsertionError() {
        let insertionError = NSError(domain: "insertion error", code: 0)
        let (store, sut) = makeSUT()
        
        expect(sut, toCompleteWith: insertionError, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        })
    }
    
    func test_save_doesNotDeliverDeletionErrorAfterSUTHasBeenDeallocated() {
        let store = MoviesStoreSpy()
        var sut: LocalMoviesLoader? = LocalMoviesLoader(store: store)
        
        var receivedResults = [LocalMoviesLoader.SaveResult]()
        sut?.save(makeMovies()) { result in
            receivedResults.append(result)
        }
        
        sut = nil
        store.completeDeletion(with: anyNSError())

        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterSUTHasBeenDeallocated() {
        let store = MoviesStoreSpy()
        var sut: LocalMoviesLoader? = LocalMoviesLoader(store: store)
        
        var receivedResults = [LocalMoviesLoader.SaveResult]()
        sut?.save(makeMovies()) { result in
            receivedResults.append(result)
        }
    
        store.completeDeletionSuccessfully()
        
        sut = nil
        
        store.completeInsertion(with: anyNSError())

        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (store: MoviesStoreSpy, sut: LocalMoviesLoader) {
        let store = MoviesStoreSpy()
        let sut = LocalMoviesLoader(store: store)
        trackMemoryLeaks(store, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        
        return (store, sut)
    }
    
    private func expect(
        _ sut: LocalMoviesLoader,
        toCompleteWith error: NSError?,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for save")
        var receivedError: Error?
        sut.save(makeMovies()) { result in
            if case let .failure(error) = result {
                receivedError = error
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as? NSError, error, file: file, line: line)
    }
    
    final class MoviesStoreSpy: MoviesStore {
        private(set) var messages = [Message]()
        private var deletionCompletions = [MoviesStore.DeletionCompletion]()
        private var insertionCompletions = [MoviesStore.InsertionCompletion]()
        
        enum Message: Equatable {
            case deleteCachedMovies
            case insert([Movie])
        }
        
        func deleteCachedMovies(completion: @escaping DeletionCompletion) {
            messages.append(.deleteCachedMovies)
            deletionCompletions.append(completion)
        }
        
        func insert(_ movies: [Movie], completion: @escaping InsertionCompletion) {
            messages.append(.insert(movies))
            insertionCompletions.append(completion)
        }
        
        func completeDeletion(with error: Error, at index: Int = 0) {
            deletionCompletions[index](.failure(error))
        }
        
        func completeDeletionSuccessfully(at index: Int = 0) {
            deletionCompletions[index](.success(()))
        }
        
        func completeInsertionSuccessfully(at index: Int = 0) {
            insertionCompletions[index](.success(()))
        }
        
        func completeInsertion(with error: Error, at index: Int = 0) {
            insertionCompletions[index](.failure(error))
        }
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "an error", code: 0)
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
