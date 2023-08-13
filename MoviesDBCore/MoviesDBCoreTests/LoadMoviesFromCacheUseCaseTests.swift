

import XCTest
import MoviesDBCore

final class LoadMoviesFromCacheUseCaseTests: XCTestCase {

    func test_init_doesNotSendMessage() {
        let store = MoviesStoreSpy()
        
        _ = LocalMoviesLoader(store: store)
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    func test_load_requestsCacheRetrieval() {
        let (store, sut) = makeSUT()
        
        sut.load { _ in }
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_load_failsOnCacheRetrievalError() {
        let (store, sut) = makeSUT()
        let retrievalError = anyNSError()
        
        let exp = expectation(description: "Wait for load completion")
        sut.load { receivedResult in
            if case .failure(let receivedError) = receivedResult {
                XCTAssertEqual(retrievalError, receivedError as NSError)
            } else {
                XCTFail("Should receive a failure with error. Got \(receivedResult) instead")
            }
            
            exp.fulfill()
        }
        
        store.completeRetrieval(with: retrievalError)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_load_deliversNoMoviesOnEmptyCache() {
        let (store, sut) = makeSUT()
        
        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            
            switch result {
            case .success(let cachedMovies):
                XCTAssertEqual(cachedMovies, [])
                
            default:
                XCTFail("Should receive a success with cached movies. Got \(result) instead")
            }
           
            exp.fulfill()
        }
        
        store.completeRetrievalSuccessfully(with: [])
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (store: MoviesStoreSpy, sut: LocalMoviesLoader) {
        let store = MoviesStoreSpy()
        let sut = LocalMoviesLoader(store: store)
        trackMemoryLeaks(store, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        
        return (store, sut)
    }
}
