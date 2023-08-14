

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
        let sut = CoreDataMoviesStore()
        
        let exp = expectation(description: "Wait for retrieve completion")
        sut.retrieve { receivedResult in
            if case .success(let cachedMovies) = receivedResult {
                XCTAssertTrue(cachedMovies.isEmpty)
            } else {
                XCTFail("Should received a success with an empty movies array, got \(receivedResult) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = CoreDataMoviesStore()
        
        let exp1 = expectation(description: "Wait for first retrieve completion")
        sut.retrieve { receivedResult in
            if case .success(let cachedMovies) = receivedResult {
                XCTAssertTrue(cachedMovies.isEmpty)
            } else {
                XCTFail("Should received a success with an empty movies array, got \(receivedResult) instead")
            }
            
            exp1.fulfill()
        }
        
        let exp2 = expectation(description: "Wait for second retrieve completion")
        sut.retrieve { receivedResult in
            if case .success(let cachedMovies) = receivedResult {
                XCTAssertTrue(cachedMovies.isEmpty)
            } else {
                XCTFail("Should received a success with an empty movies array, got \(receivedResult) instead")
            }
            
            exp2.fulfill()
        }
        
        wait(for: [exp1, exp2], timeout: 1.0)
    }
}
