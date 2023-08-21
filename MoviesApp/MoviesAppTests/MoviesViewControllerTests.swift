

import XCTest
import UIKit
import MoviesCore

final class MoviesViewController: UITableViewController {
    
    private let loader: MoviesLoader
    
    init(loader: MoviesLoader) {
        self.loader = loader
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadMovies), for: .valueChanged)
        loadMovies()
    }
    
    @objc
    private func loadMovies() {
        loader.load { _ in }
    }
}

final class MoviesViewControllerTests: XCTestCase {

    func test_loadActions_requestsMoviesFromLoader() {
        let (loader, sut) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading request")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1, "Expected to request loading once")
        
        sut.simulateUserInitiatedMoviesReload()
        XCTAssertEqual(loader.loadCallCount, 2, "Expected another loading request")
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
        private(set) var loadCallCount = 0
        
        func load(completion: @escaping (MoviesLoader.Result) -> Void) {
            loadCallCount += 1
        }
    }
}

extension MoviesViewController {
    func simulateUserInitiatedMoviesReload() {
        refreshControl?.allTargets.forEach { target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach{
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
