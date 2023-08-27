

import XCTest

final class LocalMoviePosterImageDataLoader {
    
    init(store: Any) {}
}

final class LocalMoviePosterImageDataFromCacheUseCaseTests: XCTestCase {

    func test_init_doesNotSendMessgeToStoreUponFreation() {
        let store = StoreSpy()
        let sut = LocalMoviePosterImageDataLoader(store: store)
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    // MARK: - Helpers
    
    final class StoreSpy {
        private(set) var receivedMessages = [Any]()
    }
}
