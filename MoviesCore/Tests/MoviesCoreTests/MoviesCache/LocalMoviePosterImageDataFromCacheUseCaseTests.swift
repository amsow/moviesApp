

import XCTest
import MoviesCore

protocol ImageDataStore {
    func retrieveData(for url: URL)
}

final class LocalMoviePosterImageDataLoader {
    
    private let store: ImageDataStore
    
    init(store: ImageDataStore) {
        self.store = store
    }
    
    func loadImageData(from url: URL) {
        store.retrieveData(for: url)
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
        sut.loadImageData(from: url)
        
        XCTAssertEqual(store.messages, [.retrieve(dataForURL: url)])
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
        
        enum Message: Equatable {
            case retrieve(dataForURL: URL)
        }
        
        func retrieveData(for url: URL) {
            messages.append(.retrieve(dataForURL: url))
        }
    }
}
