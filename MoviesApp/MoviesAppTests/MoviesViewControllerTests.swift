

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
    
    func test_loadCompletion_rendersSuccessfullyLoadedMovies() {
        let (loader, sut) = makeSUT()
        let movie0 = makeMovie(id: 0, title: "Movie 0", overview: "Any description")
        let movie1 = makeMovie(id: 1, title: "Movie 1", overview: "Any description")
        let movie2 = makeMovie(id: 2, title: "Movie 2", overview: "Any description")
        
        sut.loadViewIfNeeded()
        loader.completeLoadingSuccessfully(with: [movie0], at: 0)
        assertThat(sut, isRendering: [movie0], at: 0)
        
        sut.simulateUserInitiatedMoviesReload()
        loader.completeLoadingSuccessfully(with: [movie0, movie1, movie2], at: 1)
        assertThat(sut, isRendering: [movie0, movie1, movie2], at: 0)
    }
    
    func test_loadCompletion_rendersSuccessfullyLoadedEmptyMoviesAfterNotEmptyMovies() {
        let (loader, sut) = makeSUT()
        let movie0 = makeMovie(id: 0, title: "Movie 0", overview: "Any description")
        let movie1 = makeMovie(id: 1, title: "Movie 1", overview: "Any description")
        
        sut.loadViewIfNeeded()
        loader.completeLoadingSuccessfully(with: [movie0, movie1], at: 0)
        assertThat(sut, isRendering: [movie0, movie1], at: 0)
        
        sut.simulateUserInitiatedMoviesReload()
        loader.completeLoadingSuccessfully(with: [], at: 1)
        assertThat(sut, isRendering: [], at: 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (loader: LoaderSpy, sut: MoviesViewController) {
        let loader = LoaderSpy()
        let sut = MoviesViewController(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (loader, sut)
    }
    
    private func assertThat(
        _ sut: MoviesViewController,
        viewFor movie: Movie, at index: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let view = sut.movieCell(at: index)
        guard let cell = view as? MovieCell else {
            return XCTFail("Expected \(MovieCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        
        XCTAssertEqual(cell.titleLabel.text,
                       movie.title,
                       "Expected title label text to be \(movie.title) for movie cell at index \(index)",
                       file: file,
                       line: line)
        XCTAssertEqual(cell.overviewLabel.text,
                       movie.overview,
                       "Expected overview label text to be \(movie.overview) for movie cell at index \(index)",
                       file: file,
                       line: line)
        XCTAssertEqual(cell.releaseDateLabel.text,
                       movie.releaseDate.year(),
                       "Expected releaseDate label text to be \(movie.releaseDate)'s year for movie cell at index \(index)",
                       file: file,
                       line: line)
    }
    
    private func assertThat(
        _ sut: MoviesViewController,
        isRendering movies: [Movie],
        at index: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard sut.numberOfRenderedMovieViews() == movies.count else {
            return XCTFail("Expected \(movies.count) movies, got \(sut.numberOfRenderedMovieViews()) instead", file: file, line: line)
        }
        
        movies.enumerated().forEach { (index, movie) in
            assertThat(sut, viewFor: movie, at: index, file: file, line: line)
        }
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
    
    private func makeMovie(
        id: Int,
        title: String,
        overview: String,
        releaseDate: Date = Date()
    ) -> Movie {
        Movie(id: id, title: title, overview: overview, releaseDate: releaseDate, posterImageURL: URL(string: "http://image-\(id)")!)
    }
}

extension MoviesViewController {
    private var section: Int { return 0 }
    
    func simulateUserInitiatedMoviesReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    func isShowingLoadingIndicator() -> Bool {
        refreshControl?.isRefreshing ?? false
    }
    
    func numberOfRenderedMovieViews() -> Int {
        tableView.numberOfRows(inSection: section)
    }
    
    func movieCell(at row: Int) -> UITableViewCell? {
        let datasource = tableView.dataSource
       return datasource?.tableView(tableView, cellForRowAt: IndexPath(row: row, section: section))
    }
}

extension Date {
    func year() -> String {
        let calendar = Calendar(identifier: .gregorian)
        let yearComponent = calendar.component(.year, from: self)
        
        return yearComponent.description
    }
}
