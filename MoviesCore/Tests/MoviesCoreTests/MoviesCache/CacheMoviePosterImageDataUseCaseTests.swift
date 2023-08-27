

import XCTest
import MoviesCore

final class CacheMoviePosterImageDataUseCaseTests: XCTestCase {

   func test_init_doesNotSendMessageStoreUponCreation() {
       let (_, store) = makeSUT()
       
       XCTAssertTrue(store.messages.isEmpty)
   }
    
    func test_saveImageDataForURL_requestsImageDataInsertionForURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        let data = anyData()
        
        sut.save(data, for: url) { _ in }
        
        XCTAssertEqual(store.messages, [.insert(data: data, for: url)])
    }
    
    func test_saveImageDataForURL_failsOnStoreInsertionError() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(LocalMoviePosterImageDataLoader.SaveError.failed), when: {
            let insertionError = anyNSError()
            store.completeInsertion(with: insertionError)
        })
    }
    
    func test_saveImageDataForURL_succeedsOnSuccessfulStoreInsertion() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .success(()), when: {
            store.completeInsertionSuccessfully()
        })
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalMoviePosterImageDataLoader, store: ImageDataStoreSpy) {
        let store = ImageDataStoreSpy()
        let sut = LocalMoviePosterImageDataLoader(store: store)
        trackMemoryLeaks(sut, file: file, line: line)
        trackMemoryLeaks(store, file: file, line: line)
        
        return (sut, store)
    }
    
    
    private func expect(_ sut: LocalMoviePosterImageDataLoader,
                        toCompleteWith expectedResut: LocalMoviePosterImageDataLoader.SaveResult,
                        when action: () -> Void,
                        file: StaticString = #file,
                        line: UInt = #line
    ) {
        
        let exp = expectation(description: "Wait for completion")
        sut.save(anyData(), for: anyURL()) { receivedResult in
            switch (expectedResut, receivedResult) {
            case (.success, .success):
                break
                
            case (.failure(let expectedError as LocalMoviePosterImageDataLoader.SaveError), .failure(let receivedError as LocalMoviePosterImageDataLoader.SaveError)):
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
