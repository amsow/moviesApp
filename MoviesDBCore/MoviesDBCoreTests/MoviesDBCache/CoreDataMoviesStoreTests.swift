

import XCTest
import MoviesDBCore

final class CoreDataMoviesStore: MoviesStore {
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.success([]))
    }
    
    func deleteCachedMovies(completion: @escaping DeletionCompletion) {
        
    }
    
    func insert(_ movies: [MoviesDBCore.Movie], completion: @escaping InsertionCompletion) {
        
    }
}

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
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CoreDataMoviesStore {
        let sut = CoreDataMoviesStore()
        trackMemoryLeaks(sut, file: file, line: line)
        
        return sut
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
