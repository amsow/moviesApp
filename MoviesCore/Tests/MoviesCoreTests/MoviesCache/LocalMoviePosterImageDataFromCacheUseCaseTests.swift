

import XCTest

final class LocalMoviePosterImageDataLoader {
    
    init(store: Any) {}
}

final class LocalMoviePosterImageDataFromCacheUseCaseTests: XCTestCase {

    func test_init_doesNotSendMessgeToStoreUponFreation() {
        let (store, _) = makeSUT()
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    // MARK: - Private Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (store: MoviesStoreSpy, sut: LocalMoviePosterImageDataLoader) {
        let store = MoviesStoreSpy()
        let sut = LocalMoviePosterImageDataLoader(store: store)
        trackMemoryLeaks(store, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        
        return (store, sut)
    }
}
