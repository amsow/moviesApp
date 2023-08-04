
import XCTest

class HTTPClient {
    
    func request(from url: URL) {}
}

final class RemoteMoviesLoader {
    
    private let url: URL
    private let client: HTTPClient
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load() {
        client.request(from: url)
    }
}


final class LoadMoviesFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestLoad() {
        // Given
        let client = HTTPClientSpy()
        
        // When
        _ = RemoteMoviesLoader(url: URL(string: "http://any-url.com")!, client: client)
        
        // Then
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsFromURL() {
        // Given
        let url = URL(string: "http://any-url.com")!
        let client = HTTPClientSpy()
        let sut = RemoteMoviesLoader(url: url, client: client)
        
        // When
        sut.load()
        
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
