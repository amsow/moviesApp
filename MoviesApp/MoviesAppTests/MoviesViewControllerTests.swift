

import XCTest
import MoviesCore
import MoviesApp

final class MoviesViewControllerTests: XCTestCase {

    func test_loadActions_requestsMoviesFromLoader() {
        let (loader, sut) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading request")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1, "Expected to request loading once")
        
        sut.simulateUserInitiatedMoviesReload()
        XCTAssertEqual(loader.loadCallCount, 2, "Expected another loading request")
    }
    
    func test_loadingIndicator_isVisibleWhileLoadingMovies() {
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator(), "Expected to show loading indicator")
        
        loader.completeLoadingSuccessfully(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator(), "Expected no loading indicator once loading completes successfully")
        
        sut.simulateUserInitiatedMoviesReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator(), "Expected to show loading indicator a second time")
        
        loader.completeLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator(), "Expected no loading indicator once loading completes with error")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (loader: LoaderSpy, sut: MoviesViewController) {
        let loader = LoaderSpy()
        let sut = MoviesViewController(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (loader, sut)
    }
    
    final class LoaderSpy: MoviesLoader {
        private var loadCompletions = [(MoviesLoader.Result) -> Void]()
        
        var loadCallCount: Int {
            loadCompletions.count
        }
        
        func load(completion: @escaping (MoviesLoader.Result) -> Void) {
            loadCompletions.append(completion)
        }
        
        func completeLoadingSuccessfully(with movies: [Movie] = [], at index: Int) {
            loadCompletions[index](.success(movies))
        }
        
        func completeLoadingWithError(_ error: Error = NSError(domain: "an error", code: 0), at index: Int) {
            loadCompletions[index](.failure(error))
        }
    }
}

extension MoviesViewController {
    func simulateUserInitiatedMoviesReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    func isShowingLoadingIndicator() -> Bool {
        refreshControl?.isRefreshing ?? false
    }
}
