
import XCTest

class HTTPClient {
    
    func request(from url: URL) {}
}

final class RemoteMoviesLoader {
    
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load() {
        client.request(from: URL(string: "http://any-url.com")!)
    }
}


final class LoadMoviesFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestLoad() {
        // Given
        let client = HTTPClientSpy()
        
        // When
        _ = RemoteMoviesLoader(client: client)
        
        // Then
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestsFromURL() {
        // Given
        let client = HTTPClientSpy()
        let sut = RemoteMoviesLoader(client: client)
        
        // When
        sut.load()
        
        // Then
        XCTAssertNotNil(client.requestedURL)
    }
   
    
    final class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?
        
        override func request(from url: URL) {
            requestedURL = url
        }
    }
}
