

import XCTest

final class MoviePosterImageDataLoader {
    init(client: Any) {}
}

final class LoadMoviePosterImageDataFromRemoteUseCaseTests: XCTestCase {
   
    func test_init_doesNotPerformAnyURLLoadRequest() {
        let client = HTTPClientSpy()
        _ = MoviePosterImageDataLoader(client: client)
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    // MARK: - Helpers
    
    private final class HTTPClientSpy {
        private(set) var requestedURLs = [URL]()
    }
}
