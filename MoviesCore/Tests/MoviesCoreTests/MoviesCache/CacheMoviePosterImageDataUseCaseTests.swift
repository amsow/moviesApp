

import XCTest
import MoviesCore

final class CacheMoviePosterImageDataUseCaseTests: XCTestCase {

   func test_init_doesNotSendMessageStoreUponCreation() {
       let (_, store) = makeSUT()
       
       XCTAssertTrue(store.messages.isEmpty)
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
