

import XCTest
import MoviesCore

final class LoadMoviePosterImageDataFromRemoteUseCaseTests: XCTestCase {
   
    func test_init_doesNotPerformAnyURLLoadRequest() {
        let (client, _) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsDataFromURL() {
        let url = anyURL()
        let (client, sut) = makeSUT()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadImageDataFromURL_requestsDataFromURLTwice() {
        let url = anyURL()
        let (client, sut) = makeSUT()
        
        _ = sut.loadImageData(from: url) { _ in }
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_loadImageDataFromURL_deliversConnectivityErrorOnClientError() {
        let (client, sut) = makeSUT()
        let clientError = anyNSError()
        
        expect(sut, toCompleteWith: failureResult(.connectivity), when: {
            client.complete(with: clientError)
        })
    }
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOnNon200HTTPResponse() {
        let (client, sut) = makeSUT()
        let httpURLResponseStatusCodeSample = [203, 400, 500, 305, 150]
        
        httpURLResponseStatusCodeSample.enumerated().forEach { (index, statusCode) in
            expect(sut, toCompleteWith: failureResult(.invalidData), when: {
                client.complete(withStatusCode: statusCode, data: anyData(), at: index)
            })
        }
    }
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOn200HTTPEmptyDataResponse() {
        let (client, sut) = makeSUT()
        let emptyData = Data()
        
        expect(sut, toCompleteWith: failureResult(.invalidData), when: {
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
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteMoviePosterImageDataLoader? = .init(client: client)
        
        var receivedResults = [ImageDataLoader.Result]()
        _ = sut?.loadImageData(from: anyURL()) { result in
            receivedResults.append(result)
        }
        
        sut = nil
        
        client.complete(withStatusCode: 200, data: anyData())
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    func test_cancelLoadImageDataURLTask_cancelsClientURLRequest() {
        let (client, sut) = makeSUT()
        let url = URL(string: "http://image-data-0.com")!

        let task = sut.loadImageData(from: url) { _ in }
        XCTAssertTrue(client.cancelledURLs.isEmpty, "Expected no cancelled url request until task is cancelled")

        task.cancel()
        XCTAssertEqual(client.cancelledURLs, [url], "Expected 1 cancelled url request once task is cancelled")
    }
    
    func test_loadImageDataFromURL_doesNotDeliversResultAfterCancellingTask() {
        let (client, sut) = makeSUT()
        let url = URL(string: "http://image-data-0.com")!
        
        var receivedResults = [ImageDataLoader.Result]()
        let task = sut.loadImageData(from: url) { result in
            receivedResults.append(result)
        }
        
        task.cancel()
        client.complete(with: anyNSError())
        
        XCTAssertTrue(receivedResults.isEmpty, "Expected no result after cancelling the ongoing url request")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (client: HTTPClientSpy, sut: ImageDataLoader) {
        let client = HTTPClientSpy()
        let sut = RemoteMoviePosterImageDataLoader(client: client)
        trackMemoryLeaks(client, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        
        return (client, sut)
    }
    
    private func failureResult( _ error: RemoteMoviePosterImageDataLoader.Error) -> ImageDataLoader.Result {
        return .failure(error)
    }
    
    private func expect(
        _ sut: ImageDataLoader,
        toCompleteWith expectedResult: ImageDataLoader.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load completion")
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (expectedResult, receivedResult) {
            case let (.success(expectedData), .success(receivedData)):
                XCTAssertEqual(expectedData, receivedData, "Expected to receive \(expectedData) but got \(receivedData) instead", file: file, line: line)
                
            case let (.failure(expectedError as RemoteMoviePosterImageDataLoader.Error), .failure(receivedError as RemoteMoviePosterImageDataLoader.Error)):
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
