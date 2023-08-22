

import XCTest
import MoviesCore

final class MoviePosterImageDataLoader {
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    func loadImageData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        client.request(from: url) { result in
            switch result {
            case .success(let (data, response)):
                if response.statusCode != 200 {
                    completion(.failure(.invalidData))
                } else if data.isEmpty && response.statusCode == 200 {
                    completion(.failure(.invalidData))
                } else {
                    completion(.success(data))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

final class LoadMoviePosterImageDataFromRemoteUseCaseTests: XCTestCase {
   
    func test_init_doesNotPerformAnyURLLoadRequest() {
        let (client, _) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsDataFromURL() {
        let url = anyURL()
        let (client, sut) = makeSUT()
        
        sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadImageDataFromURL_requestsDataFromURLTwice() {
        let url = anyURL()
        let (client, sut) = makeSUT()
        
        sut.loadImageData(from: url) { _ in }
        sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_loadImageDataFromURL_deliversConnectivityErrorOnClientError() {
        let url = anyURL()
        let (client, sut) = makeSUT()
        let clientError = anyNSError()
        
        var receivedError: Error?
        let exp = expectation(description: "Wait for load completion")
        sut.loadImageData(from: url) { result in
            if case .failure(let error) = result {
                receivedError = error
            }
            exp.fulfill()
        }
        
        client.complete(with: clientError)
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as? MoviePosterImageDataLoader.Error, .connectivity)
    }
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOnNon200HTTPResponse() {
        let url = anyURL()
        let (client, sut) = makeSUT()
        let httpURLResponseStatusCodeSample = [203, 400, 500, 305, 150]
        
        httpURLResponseStatusCodeSample.enumerated().forEach { (index, statusCode) in
            let exp = expectation(description: "Wait for load")
            var receivedError: Error?
            sut.loadImageData(from: url) { result in
                if case .failure(let error) = result {
                    receivedError = error
                }
                exp.fulfill()
            }
            
            client.complete(withStatusCode: statusCode, data: Data(), at: index)
            
            wait(for: [exp], timeout: 1.0)
            
            XCTAssertEqual(receivedError as? MoviePosterImageDataLoader.Error, .invalidData)
        }
    }
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOn200HTTPEmptyDataResponse() {
        let url = anyURL()
        let (client, sut) = makeSUT()
        let emptyData = Data()
        
        var receivedError: Error?
        let exp = expectation(description: "Wait for load")
        sut.loadImageData(from: url) { result in
            if case .failure(let error) = result {
                receivedError = error
            }
            exp.fulfill()
        }
        
        client.complete(withStatusCode: 200, data: emptyData)
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as? MoviePosterImageDataLoader.Error, .invalidData)
    }
    
    func test_loadImageDataFromURL_deliversReceivedNonDataOn200HTTPResponse() {
        let url = anyURL()
        let (client, sut) = makeSUT()
        
        let exp = expectation(description: "Wait for load")
        sut.loadImageData(from: url) { result in
            if case .success(let data) = result {
                XCTAssertFalse(data.isEmpty)
            }
            
            exp.fulfill()
        }
        
        client.complete(withStatusCode: 200, data: Data("non-empty data".utf8))
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> (client: HTTPClientSpy, sut: MoviePosterImageDataLoader) {
        let client = HTTPClientSpy()
        let sut = MoviePosterImageDataLoader(client: client)
        
        return (client, sut)
    }
}
