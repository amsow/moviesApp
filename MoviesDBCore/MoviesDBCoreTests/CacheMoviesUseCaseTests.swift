
import XCTest

protocol MoviesStore {
    func deleteCachedMovies(completion: @escaping (Error?) -> Void)
    func insert()
}

final class LocalMoviesLoader {
    
    private let store: MoviesStore
    
    init(store: MoviesStore) {
        self.store = store
    }
    
    func save() {
        store.deleteCachedMovies { error in
            if error == nil {
                self.store.insert()
            }
        }
    }
}

final class CacheMoviesUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageCacheUponCreation() {
        let store = MoviesStoreSpy()
        _ = LocalMoviesLoader(store: store)
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    func test_save_requestsCacheDeletion() {
        let store = MoviesStoreSpy()
        let sut = LocalMoviesLoader(store: store)
        
        sut.save()
        
        XCTAssertEqual(store.messages, [.deleteCachedMovies])
    }
    
    func test_save_doesNotRequestInsertionOnCacheDeletionError() {
        let deletionError = NSError(domain: "deletion error", code: 0)
        let store = MoviesStoreSpy()
        let sut = LocalMoviesLoader(store: store)
        
        sut.save()
        
        store.completeDeletion(with: deletionError)
        XCTAssertEqual(store.messages, [.deleteCachedMovies])
    }
    
    final class MoviesStoreSpy: MoviesStore {
        private(set) var messages = [Message]()
        private var deletionCompletions = [(Error?) -> Void]()
        
        enum Message {
            case deleteCachedMovies
            case insert
        }
        
        func deleteCachedMovies(completion: @escaping (Error?) -> Void) {
            messages.append(.deleteCachedMovies)
            deletionCompletions.append(completion)
        }
        
        func insert() {
            messages.append(.insert)
        }
        
        func completeDeletion(with error: Error, at index: Int = 0) {
            deletionCompletions[index](error)
        }
    }
}
