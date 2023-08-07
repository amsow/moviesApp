
import XCTest
import MoviesDBCore

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
        sut.load { result in
            if case .failure(let error as RemoteMoviesLoader.Error) = result {
                capturedErrors.append(error)
            }
        }
        
        client.complete(with: anyError)
        
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (client, sut) = makeSUT()
        let sample = [400, 403, 305, 150, 500, 203]
        
        sample.enumerated().forEach { index, code in
            var capturedErrors = [RemoteMoviesLoader.Error]()
            sut.load { result in
                if case .failure(let error as RemoteMoviesLoader.Error) = result {
                    capturedErrors.append(error)
                }
            }
            
            client.complete(withStatusCode: code, at: index)
            
            
            XCTAssertEqual(capturedErrors, [.invalidData])
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (client, sut) = makeSUT()
        
        var receivedErrors = [RemoteMoviesLoader.Error]()
        sut.load { result in
            if case .failure(let error as RemoteMoviesLoader.Error) = result {
                receivedErrors.append(error)
            }
        }
        
        let invalidData = Data("invalid data".utf8)
        client.complete(withStatusCode: 200, data: invalidData)
        
        XCTAssertEqual(receivedErrors, [.invalidData])
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
        
        private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
        
        func request(from url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = .init(), at index: Int = 0) {
            let url = requestedURLs[index]
            let response = HTTPURLResponse(url: url, statusCode: code, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success((data, response)))
        }
    }
}
