

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
        
        sut.load()
        
        XCTAssertEqual(store.messages, [.retrieve])
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
