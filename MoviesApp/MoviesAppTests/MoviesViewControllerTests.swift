

import XCTest
import UIKit
import MoviesCore

final class MoviesViewController: UIViewController {
    
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
        loader.load { _ in
            
        }
    }
}

final class MoviesViewControllerTests: XCTestCase {

    func test_init_doesNotLoad() {
        let (loader, _) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_loadsMovies() {
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
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
