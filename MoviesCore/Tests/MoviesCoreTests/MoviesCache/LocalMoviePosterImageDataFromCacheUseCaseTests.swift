

import XCTest
import MoviesCore

final class LocalMoviePosterImageDataFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotSendMessgeToStoreUponFreation() {
        let (store, _) = makeSUT()
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsStoredDataForURL() {
        let (store, sut) = makeSUT()
        
        let url = anyURL()
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(store.messages, [.retrieve(dataForURL: url)])
    }
    
    func test_loadImageDataFromURL_failsOnStoreError() {
        let (store, sut) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(LocalMoviePosterImageDataLoader.RetrievalError.failed), when: {
            store.completeRetrievalWithError(anyNSError(), at: 0)
        })
    }
    
    func test_loadImageFataFromURL_deliversNotFoundErrorOnNotFound() {
        let (store, sut) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(LocalMoviePosterImageDataLoader.RetrievalError.notFound), when: {
            store.completeRetrievalWithData(.none, at: 0)
        })
    }
    
    func test_loadImageDataFromURL_deliversFoundDataForURL() {
        let (store, sut) = makeSUT()
        let expectedData = anyData()
        
        expect(sut, toCompleteWith: .success(expectedData), when: {
            store.completeRetrievalWithData(expectedData, at: 0)
        })
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterCancellingTask() {
        let (store, sut) = makeSUT()
        let foundData = anyData()
        
        var receivedResults = [ImageDataLoader.Result]()
        let task = sut.loadImageData(from: anyURL()) { receivedResults.append($0) }
        task.cancel()
        
        store.completeRetrievalWithData(foundData, at: 0)
        store.completeRetrievalWithData(.none, at: 0)
        store.completeRetrievalWithError(anyNSError(), at: 0)
        
        XCTAssertTrue(receivedResults.isEmpty, "Expected no received results after cancelling task")
    }
    
    // MARK: - Private Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (store: ImageDataStoreSpy, sut: LocalMoviePosterImageDataLoader) {
        let store = ImageDataStoreSpy()
        let sut = LocalMoviePosterImageDataLoader(store: store)
        trackMemoryLeaks(store, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        
        return (store, sut)
    }
    
    private func expect(_ sut: ImageDataLoader,
                        toCompleteWith expectedResut: ImageDataLoader.Result,
                        when action: () -> Void,
                        file: StaticString = #file,
                        line: UInt = #line
    ) {
        
        let exp = expectation(description: "Wait for completion")
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (expectedResut, receivedResult) {
            case (.success(let expectedData), .success(let receivedData)):
                XCTAssertEqual(expectedData, receivedData,
                               "Expected success with data \(expectedData) but got this \(receivedData)",
                               file: file,
                               line: line)
                
            case (.failure(let expectedError as LocalMoviePosterImageDataLoader.RetrievalError), .failure(let receivedError as LocalMoviePosterImageDataLoader.RetrievalError)):
                XCTAssertEqual(expectedError, receivedError,
                               "Expected failure with error \(expectedError) but got this error \(receivedError) instead",
                               file: file,
                               line: line)
                
            default:
                XCTFail("Expected to get result \(expectedResut), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}
