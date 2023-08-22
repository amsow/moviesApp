

import XCTest
import MoviesCore

final class MoviePosterImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) {
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
        let (client, sut) = makeSUT()
        let clientError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(.connectivity), when: {
            client.complete(with: clientError)
        })
    }
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOnNon200HTTPResponse() {
        let (client, sut) = makeSUT()
        let httpURLResponseStatusCodeSample = [203, 400, 500, 305, 150]
        
        httpURLResponseStatusCodeSample.enumerated().forEach { (index, statusCode) in
            expect(sut, toCompleteWith: .failure(.invalidData), when: {
                client.complete(withStatusCode: statusCode, data: anyData(), at: index)
            })
        }
    }
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOn200HTTPEmptyDataResponse() {
        let (client, sut) = makeSUT()
        let emptyData = Data()
        
        expect(sut, toCompleteWith: .failure(.invalidData), when: {
            client.complete(withStatusCode: 200, data: emptyData)
        })
    }
    
    func test_loadImageDataFromURL_deliversReceivedNonDataOn200HTTPResponse() {
        let (client, sut) = makeSUT()
        let nonEmptyData = anyData()
        expect(sut, toCompleteWith: .success(nonEmptyData), when: {
            client.complete(withStatusCode: 200, data: nonEmptyData)
        })
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> (client: HTTPClientSpy, sut: MoviePosterImageDataLoader) {
        let client = HTTPClientSpy()
        let sut = MoviePosterImageDataLoader(client: client)
        
        return (client, sut)
    }
    
    private func expect(
        _ sut: MoviePosterImageDataLoader,
        toCompleteWith expectedResult: MoviePosterImageDataLoader.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load completion")
        sut.loadImageData(from: anyURL()) { receivedResult in
            switch (expectedResult, receivedResult) {
            case let (.success(expectedData), .success(receivedData)):
                XCTAssertEqual(expectedData, receivedData, "Expected to receive \(expectedData) but got \(receivedData) instead", file: file, line: line)
                
            case let (.failure(expectedError), .failure(receivedError)):
                XCTAssertEqual(expectedError, receivedError, "Expected to receive \(expectedError) but got \(receivedError) instead", file: file, line: line)
                
            default:
                XCTFail("Expected \(expectedResult) but got \(receivedResult) instead", file: file, line: line)
                
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}
