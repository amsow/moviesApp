

import XCTest
import MoviesDBCore

final class CoreDataMoviesStoreTests: XCTestCase {
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieve: .success([]))
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieve: .success([]))
        expect(sut, toRetrieve: .success([]))
    }
    
    func test_retrieve_deliversFoundMoviesOnNonEmptyCache() {
        let sut = makeSUT()
        let movies = makeMovies()
        
        insert(movies, into: sut)
        
        expect(sut, toRetrieve: .success(movies))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let movies = makeMovies()
        
        insert(movies, into: sut)
        
        expect(sut, toRetrieve: .success(movies))
        expect(sut, toRetrieve: .success(movies))
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        let insertionError = insert(makeMovies(), into: sut)
        
        XCTAssertNil(insertionError, "Expected to insert movies successfully")
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        
        insert(makeMovies(), into: sut)
        
        let seondInsertionError = insert(makeMovies(), into: sut)
        
        XCTAssertNil(seondInsertionError, "Expected to override cache successfully")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CoreDataMoviesStore {
        /// `/dev/null` behaves as a real file url location to enable read/write operations but without any artifact (as it's fake actually :-) )
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataMoviesStore(storeURL: storeURL)
        trackMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    @discardableResult
    private func insert(
        _ movies: [Movie] = makeMovies(),
        into sut: CoreDataMoviesStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Error? {
        let exp = expectation(description: "Wait for insertion completion")
        var insertionError: Error?
        sut.insert(movies) { insertionResult in
            if case .failure(let error) = insertionResult {
                insertionError = error
                XCTFail("Expected to insert movies successfully but got error \(error)", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        return insertionError
    }
    
    private func expect(
        _ sut: CoreDataMoviesStore,
        toRetrieve expectedResult: MoviesStore.RetrievalResult,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for retrieve completion")
        sut.retrieve { receivedResult in
            
            switch (receivedResult, expectedResult) {
            case let (.success(receivedMovies), .success(expectedMovies)):
                XCTAssertEqual(receivedMovies, expectedMovies, file: file, line: line)
                
            default:
                XCTFail("Should received a success with an empty movies array, got \(receivedResult) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
