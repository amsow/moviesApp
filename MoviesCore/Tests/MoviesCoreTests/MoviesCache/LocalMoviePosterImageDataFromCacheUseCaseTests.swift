

import XCTest
import MoviesCore

protocol ImageDataStore {
    func retrieveData(for url: URL, completion: @escaping (Error?) -> Void)
}

final class LocalMoviePosterImageDataLoader {
    
    private let store: ImageDataStore
    
    init(store: ImageDataStore) {
        self.store = store
    }
    
    func loadImageData(from url: URL, completion: @escaping (Error?) -> Void) {
        store.retrieveData(for: url) { error in
            completion(error)
        }
    }
}

final class LocalMoviePosterImageDataFromCacheUseCaseTests: XCTestCase {

    func test_init_doesNotSendMessgeToStoreUponFreation() {
        let (store, _) = makeSUT()
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsStoredDataForURL() {
        let (store, sut) = makeSUT()
        
        let url = anyURL()
        sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(store.messages, [.retrieve(dataForURL: url)])
    }
    
    func test_loadImageDataFromURL_failsOnStoreError() {
        let (store, sut) = makeSUT()
        
        let retrievalError = anyNSError()
        let exp = expectation(description: "Wait for retrive completion")
        
        var receivedError: Error?
        sut.loadImageData(from: anyURL()) { error in
            receivedError = error
            exp.fulfill()
        }
        
        store.completeWithError(retrievalError, at: 0)
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(retrievalError, receivedError as? NSError)
    }
    
    // MARK: - Private Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (store: ImageDataStoreSpy, sut: LocalMoviePosterImageDataLoader) {
        let store = ImageDataStoreSpy()
        let sut = LocalMoviePosterImageDataLoader(store: store)
        trackMemoryLeaks(store, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        
        return (store, sut)
    }
    
    final class ImageDataStoreSpy: ImageDataStore {
        private(set) var messages = [Message]()
        private var retrievalCompletions = [(Error?) -> Void]()
        
        enum Message: Equatable {
            case retrieve(dataForURL: URL)
        }
        
        func retrieveData(for url: URL, completion: @escaping (Error?) -> Void) {
            messages.append(.retrieve(dataForURL: url))
            retrievalCompletions.append(completion)
        }
        
        func completeWithError(_ error: Error, at index: Int) {
            retrievalCompletions[index](error)
        }
    }
}
