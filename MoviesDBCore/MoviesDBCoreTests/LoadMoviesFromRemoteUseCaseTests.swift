
import XCTest

protocol HTTPClient {
    
    func request(from url: URL, completion: @escaping (Error?) -> Void)
}

final class RemoteMoviesLoader {
    
    private let url: URL
    private let client: HTTPClient
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load(completion: @escaping (Error?) -> Void) {
        client.request(from: url, completion: completion)
    }
}


final class LoadMoviesFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestLoad() {
        // Given & When
        let (client, _) = makeSUT()
        
        // Then
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsFromURL() {
        // Given
        let url = URL(string: "http://an-url.com")!
        let (client, sut) = makeSUT(url: url)
        
        // When
        sut.load { _ in }
        
        // Then
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsTwiceFromURL() {
        // Given
        let url = URL(string: "http://a-given-url.com")!
        let (client, sut) = makeSUT(url: url)
        
        // When
        sut.load { _ in }
        sut.load { _ in }
        
        // Then
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (client, sut) = makeSUT()
        let anyError = NSError(domain: "any error", code: 0)
        let loadCompletionExpectation = expectation(description: "Wait for load completion")
        
        sut.load { error in
            XCTAssertNotNil(error)
            XCTAssertEqual(anyError, error as? NSError)
            
            loadCompletionExpectation.fulfill()
        }
        
        client.complete(with: anyError)
        wait(for: [loadCompletionExpectation], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "http://any-url.com")!) -> (HTTPClientSpy, RemoteMoviesLoader) {
        let client = HTTPClientSpy()
        let sut = RemoteMoviesLoader(url: url, client: client)
        
        return (client, sut)
    }
   
    
    final class HTTPClientSpy: HTTPClient {
        private(set) var requestedURLs = [URL]()
        private var errorCompletions = [(Error?) -> Void]()
        
        func request(from url: URL, completion: @escaping (Error?) -> Void) {
            requestedURLs.append(url)
            errorCompletions.append(completion)
        }
        
        func complete(with error: Error) {
            errorCompletions[0](error)
        }
    }
}
