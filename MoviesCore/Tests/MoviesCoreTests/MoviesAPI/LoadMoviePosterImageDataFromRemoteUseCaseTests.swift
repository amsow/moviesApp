

import XCTest
import MoviesCore

final class MoviePosterImageDataLoader {
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    enum Error: Swift.Error {
        case connectivity
    }
    
    func loadImageData(from url: URL, completion: @escaping (Error?) -> Void) {
        client.request(from: url) { result in
            completion(Error.connectivity)
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
        sut.loadImageData(from: url) { error in
            receivedError = error
            exp.fulfill()
        }
        
        client.complete(with: clientError)
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as? MoviePosterImageDataLoader.Error, .connectivity)
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> (client: HTTPClientSpy, sut: MoviePosterImageDataLoader) {
        let client = HTTPClientSpy()
        let sut = MoviePosterImageDataLoader(client: client)
        
        return (client, sut)
    }
}
