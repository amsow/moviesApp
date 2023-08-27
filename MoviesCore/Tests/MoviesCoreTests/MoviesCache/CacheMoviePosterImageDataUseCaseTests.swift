

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
        
        sut.save(data, for: url)
        
        XCTAssertEqual(store.messages, [.insert(data: data, for: url)])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalMoviePosterImageDataLoader, store: ImageDataStoreSpy) {
        let store = ImageDataStoreSpy()
        let sut = LocalMoviePosterImageDataLoader(store: store)
        trackMemoryLeaks(sut, file: file, line: line)
        trackMemoryLeaks(store, file: file, line: line)
        
        return (sut, store)
    }
}
