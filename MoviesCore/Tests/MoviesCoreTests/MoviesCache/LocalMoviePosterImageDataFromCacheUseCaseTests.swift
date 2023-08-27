

import XCTest
import MoviesCore

protocol ImageDataStore {
    func retrieveData(for url: URL, completion: @escaping (Result<Data?, Error>) -> Void)
}

final class LocalMoviePosterImageDataLoader {
    
    private let store: ImageDataStore
    
    init(store: ImageDataStore) {
        self.store = store
    }
    
    enum RetrievalError: Error {
        case notFound
        case failed
    }
    
    func loadImageData(from url: URL, completion: @escaping (Data?, Error?) -> Void) {
        store.retrieveData(for: url) { result in
            
            switch result {
            case .success(let data):
                if data == nil {
                    completion(nil, RetrievalError.notFound)
                } else {
                    completion(data!, nil)
                }
                
            case .failure:
                completion(nil, RetrievalError.failed)
            }
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
        sut.loadImageData(from: url) { (_, _) in }
        
        XCTAssertEqual(store.messages, [.retrieve(dataForURL: url)])
    }
    
    func test_loadImageDataFromURL_failsOnStoreError() {
        let (store, sut) = makeSUT()
        
        let retrievalError = LocalMoviePosterImageDataLoader.RetrievalError.failed
        let exp = expectation(description: "Wait for retrive completion")
        
        var receivedError: Error?
        sut.loadImageData(from: anyURL()) { (_, error) in
                receivedError = error
            exp.fulfill()
        }
        
        store.completeRetrievalWithError(retrievalError, at: 0)
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as? LocalMoviePosterImageDataLoader.RetrievalError, .failed)
    }
    
    func test_loadImageFataFromURL_deliversNotFoundErrorOnNotFound() {
        let (store, sut) = makeSUT()
        
        let exp = expectation(description: "wait for retrieval completion")
        sut.loadImageData(from: anyURL()) { (_, error) in
           // if case .failure(let error) = result {
                XCTAssertEqual(error as? LocalMoviePosterImageDataLoader.RetrievalError, .notFound)
       //     }
           
            exp.fulfill()
        }
        store.completeRetrievalWithData(nil, at: 0)
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadImageDataFromURL_deliversFoundDataForURL() {
        let (store, sut) = makeSUT()
        
        let expectedData = anyData()
        let exp = expectation(description: "Wait for retrieval completion")
        var receivedData: Data?
        sut.loadImageData(from: anyURL()) { (data, _) in
            receivedData = data
            exp.fulfill()
        }
        
        store.completeRetrievalWithData(expectedData, at: 0)
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(expectedData, receivedData)
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
        private var retrievalCompletions = [(Result<Data?, Error>) -> Void]()
        
        enum Message: Equatable {
            case retrieve(dataForURL: URL)
        }
        
        func retrieveData(for url: URL, completion: @escaping (Result<Data?, Error>) -> Void) {
            messages.append(.retrieve(dataForURL: url))
            retrievalCompletions.append(completion)
        }
        
        func completeRetrievalWithError(_ error: Error, at index: Int) {
            retrievalCompletions[index](.failure(error))
        }
        
        func completeRetrievalWithData(_ data: Data?, at index: Int) {
            retrievalCompletions[index](.success(data))
        }
    }
}
