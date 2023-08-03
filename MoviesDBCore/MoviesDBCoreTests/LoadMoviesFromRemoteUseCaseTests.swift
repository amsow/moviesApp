
import XCTest

final class RemoteMoviesLoader {
    init(client: Any) {}
}


final class LoadMoviesFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestLoad() {
        // Given
        let client = HTTPClient()
        
        // When
        _ = RemoteMoviesLoader(client: client)
        
        // Then
        XCTAssertNil(client.requestedURL)
    }
   
    
    final class HTTPClient {
        var requestedURL: URL?
    }
}
