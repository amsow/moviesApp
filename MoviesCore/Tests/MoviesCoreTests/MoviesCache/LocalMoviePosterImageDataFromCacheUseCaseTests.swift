

import XCTest
import MoviesCore

protocol ImageDataStore {
    typealias RetrievalResult = Result<Data?, Error>
    
    func retrieveData(for url: URL, completion: @escaping (RetrievalResult) -> Void)
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
    
    func loadImageData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        store.retrieveData(for: url) { result in
            
            switch result {
            case .success(let data):
                if data == nil {
                    completion(.failure(RetrievalError.notFound))
                } else {
                    completion(.success(data!))
                }
                
            case .failure:
                completion(.failure(RetrievalError.failed))
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
        sut.loadImageData(from: url) { _ in }
        
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
    
    // MARK: - Private Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (store: ImageDataStoreSpy, sut: LocalMoviePosterImageDataLoader) {
        let store = ImageDataStoreSpy()
        let sut = LocalMoviePosterImageDataLoader(store: store)
        trackMemoryLeaks(store, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        
        return (store, sut)
    }
    
    private func expect(_ sut: LocalMoviePosterImageDataLoader,
                        toCompleteWith expectedResut: ImageDataLoader.Result,
                        when action: () -> Void,
                        file: StaticString = #file,
                        line: UInt = #line
    ) {
        
        let exp = expectation(description: "Wait for completion")
        sut.loadImageData(from: anyURL()) { receivedResult in
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
    
    final class ImageDataStoreSpy: ImageDataStore {
        private(set) var messages = [Message]()
        private var retrievalCompletions = [(ImageDataStore.RetrievalResult) -> Void]()
        
        enum Message: Equatable {
            case retrieve(dataForURL: URL)
        }
        
        func retrieveData(for url: URL, completion: @escaping (ImageDataStore.RetrievalResult) -> Void) {
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
