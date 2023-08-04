
import XCTest

class HTTPClient {
    
    func request(from url: URL) {}
}

final class RemoteMoviesLoader {
    
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load(from url: URL) {
        client.request(from: url)
    }
}


final class LoadMoviesFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestLoad() {
        // Given
        let client = HTTPClientSpy()
        
        // When
        _ = RemoteMoviesLoader(client: client)
        
        // Then
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsFromURL() {
        // Given
        let client = HTTPClientSpy()
        let sut = RemoteMoviesLoader(client: client)
        let url = URL(string: "http://any-url.com")!
        
        // When
        sut.load(from: url)
        
        // Then
        XCTAssertEqual(client.requestedURLs, [url])
    }
   
    
    final class HTTPClientSpy: HTTPClient {
        private(set) var requestedURLs = [URL]()
        
        override func request(from url: URL) {
            requestedURLs.append(url)
        }
    }
}
