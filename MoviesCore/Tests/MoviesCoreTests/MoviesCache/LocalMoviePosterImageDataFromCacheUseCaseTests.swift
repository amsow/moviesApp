

import XCTest

final class LocalMoviePosterImageDataLoader {
    
    init(store: Any) {}
}

final class LocalMoviePosterImageDataFromCacheUseCaseTests: XCTestCase {

    func test_init_doesNotSendMessgeToStoreUponFreation() {
        let store = MoviesStoreSpy()
        let sut = LocalMoviePosterImageDataLoader(store: store)
        
        XCTAssertTrue(store.messages.isEmpty)
    }
}
