

import XCTest
import MoviesDBCore

final class LoadMoviesFromCacheUseCaseTests: XCTestCase {

    func test_init_doesNotSendMessage() {
        let store = MoviesStoreSpy()
        
        _ = LocalMoviesLoader(store: store)
        
        XCTAssertTrue(store.messages.isEmpty)
    }
}
