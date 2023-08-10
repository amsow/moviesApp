
import XCTest

final class LocalMoviesLoader {
    init(store: Any) {}
}

final class CacheMoviesUseCaseTests: XCTestCase {

    func test_init_doesNotMessageCacheUponCreation() {
        let store = MoviesStoreSpy()
        _ = LocalMoviesLoader(store: store)
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    final class MoviesStoreSpy {
        var messages = [String]()
    }
}
