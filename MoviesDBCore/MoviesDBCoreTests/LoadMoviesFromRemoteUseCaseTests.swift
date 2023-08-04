
import XCTest

protocol HTTPClient {
    
    func request(from url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> Void)
}

final class RemoteMoviesLoader {
    
    private let url: URL
    private let client: HTTPClient
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    func load(completion: @escaping (Error) -> Void) {
        client.request(from: url) { error, response in
            if error != nil {
                completion(.connectivity)
            } else if response?.statusCode != 200 {
                completion(.invalidData)
            }
        }
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
        
        var capturedErrors = [RemoteMoviesLoader.Error]()
        sut.load { error in
            capturedErrors.append(error)
        }
        
        client.complete(with: anyError)
        
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (client, sut) = makeSUT()
        let sample = [400, 403, 305, 150, 500, 203]
        
        sample.enumerated().forEach { index, code in
            var capturedErrors = [RemoteMoviesLoader.Error]()
            sut.load { capturedErrors.append($0) }
            
            client.complete(withStatusCode: code, at: index)
            
            
            XCTAssertEqual(capturedErrors, [.invalidData])
        }
    }
    
    
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "http://any-url.com")!) -> (HTTPClientSpy, RemoteMoviesLoader) {
        let client = HTTPClientSpy()
        let sut = RemoteMoviesLoader(url: url, client: client)
        
        return (client, sut)
    }
   
    
    final class HTTPClientSpy: HTTPClient {
        
        var requestedURLs: [URL] {
            return messages.map(\.url)
        }
        
        private var messages = [(url: URL, completion: (Error?, HTTPURLResponse?) -> Void)]()
        
        func request(from url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(error, nil)
        }
        
        func complete(withStatusCode code: Int, at index: Int = 0) {
            let url = requestedURLs[index]
            let response = HTTPURLResponse(url: url, statusCode: code, httpVersion: nil, headerFields: nil)
            messages[index].completion(nil, response)
        }
    }
}
