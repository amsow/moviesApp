

import XCTest
import MoviesCore

final class CoreDataMoviesStoreTests: XCTestCase {
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieve: .success(.none))
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieve: .success(.none))
        expect(sut, toRetrieve: .success(.none))
    }
    
    func test_retrieve_deliversFoundMoviesOnNonEmptyCache() {
        let sut = makeSUT()
        let movies = makeMovies()
        let timestamp = Date()
        
        insert(movies, timestamp: timestamp, into: sut)
        
        expect(sut, toRetrieve: .success((movies, timestamp)))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let movies = makeMovies()
        let timestamp = Date()
        
        insert(movies, timestamp: timestamp, into: sut)
        
        expect(sut, toRetrieve: .success((movies, timestamp)))
        expect(sut, toRetrieve: .success((movies, timestamp)))
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
    
    func test_insert_overridePreviouslyInsertedValues() {
        let sut = makeSUT()
        let firstInsertionTimestamp = Date()
        let latestMovies = makeOtherMovies()
        let latestTimestamp = Date()
        
        insert(makeMovies(), timestamp: firstInsertionTimestamp, into: sut)
        
        insert(latestMovies, timestamp: latestTimestamp, into: sut)
        
        expect(sut, toRetrieve: .success((latestMovies, latestTimestamp)))
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        let deletionError = deleteCache(on: sut)
        
        XCTAssertNil(deletionError)
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        deleteCache(on: sut)
        
        expect(sut, toRetrieve: .success(.none))
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        
        insert(makeMovies(), into: sut)
        
        let deletionError = deleteCache(on: sut)
        XCTAssertNil(deletionError, "Expected to delete cache successfully")
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        
        insert(makeMovies(), into: sut)
        
        deleteCache(on: sut)
        
        expect(sut, toRetrieve: .success(.none))
    }
    
    func test_storeSideEffects_runSerially_allOperations() {
        let sut = makeSUT()
        var completedOperationsInOrder = [XCTestExpectation]()
        
        let op1 = expectation(description: "Wait for deletion completion")
        sut.deleteCachedMovies { _ in
            completedOperationsInOrder.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Wait for insertion completion")
        sut.insert(makeMovies(), timestamp: Date()) { _ in
            completedOperationsInOrder.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "Wait for retrieve completion")
        sut.retrieve { _ in
            completedOperationsInOrder.append(op3)
            op3.fulfill()
        }
        
        let op4 = expectation(description: "Wait for deletion again completion")
        sut.deleteCachedMovies { _ in
            completedOperationsInOrder.append(op4)
            op4.fulfill()
        }
        
        waitForExpectations(timeout: 5)
        
        XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3, op4], "Expected operatrion to be executed exactly in this order op1 -> op2 -> op3 -> op4")
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
        timestamp: Date = Date(),
        into sut: CoreDataMoviesStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Error? {
        let exp = expectation(description: "Wait for insertion completion")
        var insertionError: Error?
        sut.insert(movies, timestamp: timestamp) { insertionResult in
            if case .failure(let error) = insertionResult {
                insertionError = error
                XCTFail("Expected to insert movies successfully but got error \(error)", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        return insertionError
    }
    
    @discardableResult
    private func deleteCache(on sut: CoreDataMoviesStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let exp = expectation(description: "Wait fot deletion completion")
        var deletionError: Error?
        sut.deleteCachedMovies { result in
            if case .failure(let error) = result {
                deletionError = error
                XCTFail("Expected to delete cache successfully. Got error \(error) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        return deletionError
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
            case let (.success(receivedCache), .success(expectedCache)):
                XCTAssertEqual(receivedCache?.movies, expectedCache?.movies, file: file, line: line)
                XCTAssertEqual(receivedCache?.timestamp, expectedCache?.timestamp, file: file, line: line)
                
            default:
                XCTFail("Should received a success with an empty movies array, got \(receivedResult) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
