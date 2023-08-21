

import XCTest

final class MoviesViewController {
    init(loader: Any) {}
}

final class MoviesViewControllerTests: XCTestCase {

    func test_init_doesNotLoad() {
        let loader = LoaderSpy()
        let sut = MoviesViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
        
    }
    
    
    // MARK: - Helpers
    
    final class LoaderSpy {
        private(set) var loadCallCount = 0
    }
}
