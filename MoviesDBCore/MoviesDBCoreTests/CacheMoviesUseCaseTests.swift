
import XCTest

protocol MoviesStore {
    func deleteCachedMovies()
}

final class LocalMoviesLoader {
    
    private let store: MoviesStore
    
    init(store: MoviesStore) {
        self.store = store
    }
    
    func save() {
        store.deleteCachedMovies()
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
    
    final class MoviesStoreSpy: MoviesStore {
        var messages = [Message]()
        
        enum Message {
            case deleteCachedMovies
        }
        
        func deleteCachedMovies() {
            messages.append(.deleteCachedMovies)
        }
    }
}
