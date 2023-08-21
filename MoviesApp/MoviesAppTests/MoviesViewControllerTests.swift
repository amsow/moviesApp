

import XCTest
import UIKit

final class MoviesViewController: UIViewController {
    
    private let loader: MoviesViewControllerTests.LoaderSpy
    
    init(loader: MoviesViewControllerTests.LoaderSpy) {
        self.loader = loader
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loader.load()
    }
}

final class MoviesViewControllerTests: XCTestCase {

    func test_init_doesNotLoad() {
        let loader = LoaderSpy()
        _ = MoviesViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_loadsMovies() {
        let loader = LoaderSpy()
        let sut = MoviesViewController(loader: loader)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    
    // MARK: - Helpers
    
    final class LoaderSpy {
        private(set) var loadCallCount = 0
        
        func load() {
            loadCallCount += 1
        }
    }
}
