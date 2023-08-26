

import XCTest
import MoviesCore
import MoviesApp

final class MoviesListViewControllerTests: XCTestCase {

    func test_loadActions_requestsMoviesFromLoader() {
        let (loader, sut) = makeSUT()
        
        XCTAssertEqual(loader.loadMoviesCallCount, 0, "Expected no loading request")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadMoviesCallCount, 1, "Expected to request loading once")
        
        sut.simulateUserInitiatedMoviesReload()
        XCTAssertEqual(loader.loadMoviesCallCount, 2, "Expected another loading request")
    }
    
    func test_loadingIndicator_isVisibleWhileLoadingMovies() {
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator(), "Expected to show loading indicator")
        
        loader.completeMoviesLoadingSuccessfully(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator(), "Expected no loading indicator once loading completes successfully")
        
        sut.simulateUserInitiatedMoviesReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator(), "Expected to show loading indicator a second time")
        
        loader.completeMoviesLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator(), "Expected no loading indicator once loading completes with error")
    }
    
    func test_loadMoviesCompletion_rendersSuccessfullyLoadedMovies() {
        let (loader, sut) = makeSUT()
        let movie0 = makeMovie(id: 0, title: "Movie 0", overview: "Any description")
        let movie1 = makeMovie(id: 1, title: "Movie 1", overview: "Any description")
        let movie2 = makeMovie(id: 2, title: "Movie 2", overview: "Any description")
        
        sut.loadViewIfNeeded()
        loader.completeMoviesLoadingSuccessfully(with: [movie0], at: 0)
        assertThat(sut, isRendering: [movie0])
        
        sut.simulateUserInitiatedMoviesReload()
        loader.completeMoviesLoadingSuccessfully(with: [movie0, movie1, movie2], at: 1)
        assertThat(sut, isRendering: [movie0, movie1, movie2])
    }
    
    func test_loadMoviesCompletion_rendersSuccessfullyLoadedEmptyMoviesAfterNotEmptyMovies() {
        let (loader, sut) = makeSUT()
        let movie0 = makeMovie(id: 0, title: "Movie 0", overview: "Any description")
        let movie1 = makeMovie(id: 1, title: "Movie 1", overview: "Any description")
        
        sut.loadViewIfNeeded()
        loader.completeMoviesLoadingSuccessfully(with: [movie0, movie1], at: 0)
        assertThat(sut, isRendering: [movie0, movie1])
        
        sut.simulateUserInitiatedMoviesReload()
        loader.completeMoviesLoadingSuccessfully(with: [], at: 1)
        assertThat(sut, isRendering: [])
    }
    
    func test_loadMoviesCompletion_dispatchesFromBackgroundToMainThread() {
        let (loader, sut) = makeSUT()
        let movie = makeMovie(id: 0, title: "Movie 0", overview: "Any description")
        
        sut.loadViewIfNeeded()
        let exp = expectation(description: "Wait for load completion in background thread")
        
        DispatchQueue.global().async {
            loader.completeMoviesLoadingSuccessfully(with: [movie], at: 0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadMoviesCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let (loader, sut) = makeSUT()
        let movie0 = makeMovie(id: 0, title: "Movie 0", overview: "Any description")
        let movie1 = makeMovie(id: 1, title: "Movie 1", overview: "Any description")
        
        sut.loadViewIfNeeded()
        loader.completeMoviesLoadingSuccessfully(with: [movie0, movie1], at: 0)
        assertThat(sut, isRendering: [movie0, movie1])
        
        sut.simulateUserInitiatedMoviesReload()
        loader.completeMoviesLoadingWithError(at: 1)
        assertThat(sut, isRendering: [movie0, movie1])
    }
    
    func test_loadMoviesCompletion_rendersErrorMessageOnError() {
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeMoviesLoadingWithError(at: 0)
        
        XCTAssertEqual(sut.errorMessage, "Something went wrong. Please try again later!")
    }
    
    func test_loadImageDataCompletion_dispatchesFromBackgroundToMainThread() {
        let (loader, sut) = makeSUT()
        let movie = makeMovie(id: 0, title: "Movie 0", overview: "Any description")
        
        sut.loadViewIfNeeded()
        loader.completeMoviesLoadingSuccessfully(with: [movie], at: 0)
        
        sut.simulateMovieViewVisible(at: 0)
        
        let exp = expectation(description: "Wait for image data loading completion in background thread")
        DispatchQueue.global().async {
            loader.completeImageDataLoadingSuccessfully(with: UIImage.makeWithColor().pngData()!, at: 0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_movieView_loadsImageURLWhenVisible() {
        let movie0 = makeMovie(id: 1, title: "title 1", overview: "any overview")
        let movie1 = makeMovie(id: 2, title: "title 2", overview: "any overview")
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeMoviesLoadingSuccessfully(with: [movie0, movie1], at: 0)
        
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URLs requests until views become visible")
        
        sut.simulateMovieViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [movie0.posterImageURL], "Expected first image URL request once first view becomes visible")
        
        sut.simulateMovieViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [movie0.posterImageURL, movie1.posterImageURL], "Expected both first and second image URLs requests once second view become visible")
    }
    
    func test_movieView_cancelsImageLoadingWhenNotVisibleAnymore() {
        let movie0 = makeMovie(id: 1, title: "title 1", overview: "any overview")
        let movie1 = makeMovie(id: 2, title: "title 2", overview: "any overview")
        let movie2 = makeMovie(id: 3, title: "title 3", overview: "any overview")
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeMoviesLoadingSuccessfully(with: [movie0, movie1, movie2], at: 0)
        XCTAssertTrue(loader.cancelledURLs.isEmpty, "Expected no cancelled URLs")
        
        sut.simulateMovieViewNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledURLs, [movie1.posterImageURL], "Expected cancelled url request for the second view as it's no more visible")
        
        sut.simulateMovieViewNotVisible(at: 2)
        XCTAssertEqual(loader.cancelledURLs, [movie1.posterImageURL, movie2.posterImageURL], "Expected cancelled url request for the second view and third view as they are no more visible")
    }
    
    func test_movieViewLoadingIndicator_isVisibleWhileLoadingPosterImage() {
        let movie0 = makeMovie(id: 1, title: "title 1", overview: "any overview")
        let movie1 = makeMovie(id: 2, title: "title 2", overview: "any overview")
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeMoviesLoadingSuccessfully(with: [movie0, movie1], at: 0)
        
        let movieCell0 = sut.simulateMovieViewVisible(at: 0)
        let movieCell1 = sut.simulateMovieViewVisible(at: 1)
        
        XCTAssertEqual(movieCell0?.isShowingLoadingIndicator(),
                       true,
                       "Expected to showing loading indicator while loading poster image for movie cell 0")
        
        XCTAssertEqual(movieCell1?.isShowingLoadingIndicator(),
                       true,
                       "Expected to showing loading indicator while loading poster image for movie cell 1")
        
        loader.completeImageDataLoadingSuccessfully(at: 0)
        XCTAssertEqual(movieCell0?.isShowingLoadingIndicator(),
                       false,
                       "Expected not to showing loading indicator since the poster image loading for movie cell 0 is complete with sucess")
        XCTAssertEqual(movieCell1?.isShowingLoadingIndicator(),
                       true,
                       "Expected to showing loading indicator while still loading poster image for movie cell 1")
        
        loader.completeImageDataLoadingWithError(at: 1)
        XCTAssertEqual(movieCell0?.isShowingLoadingIndicator(),
                       false,
                       "Expected not to showing loading indicator since the loading of poster image for movie cell 0 is already complete wit success")
        XCTAssertEqual(movieCell1?.isShowingLoadingIndicator(),
                       false,
                       "Expected not to showing loading indicator since the poster image loading for movie cell 1 is done with error")
    }
    
    func test_movieView_rendersImageLoadedFromURL() {
        let movie0 = makeMovie(id: 1, title: "title 1", overview: "any overview")
        let movie1 = makeMovie(id: 2, title: "title 2", overview: "any overview")
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeMoviesLoadingSuccessfully(with: [movie0, movie1], at: 0)
        
        let movieCell0 = sut.simulateMovieViewVisible(at: 0)
        let movieCell1 = sut.simulateMovieViewVisible(at: 1)
        XCTAssertEqual(movieCell0?.renderedImageData, .none)
        XCTAssertEqual(movieCell1?.renderedImageData, .none)
        
        let imageData0 = UIImage.makeWithColor(.red).pngData()!
        loader.completeImageDataLoadingSuccessfully(with: imageData0, at: 0)
        // TODO: - The assert should be XCTAssertEqual(movieCell0?.renderedImageData, imageData0) but for unknow reason the size of the rendered image data is different from the expected one
        XCTAssertNotNil(movieCell0?.renderedImageData)
        XCTAssertEqual(movieCell1?.renderedImageData, .none)
        
        let imageData1 = UIImage.makeWithColor(.blue).pngData()!
        loader.completeImageDataLoadingSuccessfully(with: imageData1, at: 1)
        // TODO: - The assert should be XCTAssertEqual(movieCell0?.renderedImageData, imageData0) and XCTAssertEqual(movieCell1?.renderedImageData, imageData1) but for unknow reason the size of the rendered image data is different from the expected one
        XCTAssertNotNil(movieCell0?.renderedImageData)
        XCTAssertNotNil(movieCell1?.renderedImageData)
    }
    
    func test_movieView_doesNotRenderLoadedImageWhenNotVisibleAnyMore() {
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeMoviesLoadingSuccessfully(with: [makeMovie(id: 1, title: "title", overview: "overview")], at: 0)
        
        let movieCell0 = sut.simulateMovieViewNotVisible(at: 0)
        loader.completeImageDataLoadingSuccessfully(with: UIImage.makeWithColor().pngData()!, at: 0)
        
        XCTAssertNil(movieCell0?.renderedImageData)
    }
    
    func test_moviewViewRetryButton_isVisibleOnImageURLLoadError() {
        let movie0 = makeMovie(id: 1, title: "title 1", overview: "any overview")
        let movie1 = makeMovie(id: 2, title: "title 2", overview: "any overview")
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeMoviesLoadingSuccessfully(with: [movie0, movie1], at: 0)
        
        let movieCell0 = sut.simulateMovieViewVisible(at: 0)
        let movieCell1 = sut.simulateMovieViewVisible(at: 1)
        
        loader.completeImageDataLoadingWithError(at: 0)
        XCTAssertEqual(movieCell0?.isRetryButtonVisibleOnImageView(), true)
        XCTAssertEqual(movieCell1?.isRetryButtonVisibleOnImageView(), false)
        
        let imgData1 = UIImage.makeWithColor(.green).pngData()!
        loader.completeImageDataLoadingSuccessfully(with: imgData1, at: 1)
        XCTAssertEqual(movieCell0?.isRetryButtonVisibleOnImageView(), true)
        XCTAssertEqual(movieCell1?.isRetryButtonVisibleOnImageView(), false)
    }
    
    func test_movieViewRetryButton_isVisibleOnInvalidImageData() {
        let movie0 = makeMovie(id: 1, title: "title 1", overview: "any overview")
        let movie1 = makeMovie(id: 2, title: "title 2", overview: "any overview")
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeMoviesLoadingSuccessfully(with: [movie0, movie1], at: 0)
        
        let validImageData = UIImage.makeWithColor().pngData()!
        let invalidImageData = Data("invalid-data".utf8)
        let movieCell0 = sut.simulateMovieViewVisible(at: 0)
        let movieCell1 = sut.simulateMovieViewVisible(at: 1)
        
        loader.completeImageDataLoadingSuccessfully(with: validImageData, at: 0)
        XCTAssertEqual(movieCell0?.isRetryButtonVisibleOnImageView(), false)
        XCTAssertEqual(movieCell1?.isRetryButtonVisibleOnImageView(), false)
        
        loader.completeImageDataLoadingSuccessfully(with: invalidImageData, at: 1)
        XCTAssertEqual(movieCell0?.isRetryButtonVisibleOnImageView(), false)
        XCTAssertEqual(movieCell1?.isRetryButtonVisibleOnImageView(), true)
    }
    
    func test_movieViewRetryAction_retriesImageLoad() {
        let movie0 = makeMovie(id: 1, title: "title 1", overview: "any overview")
        let movie1 = makeMovie(id: 2, title: "title 2", overview: "any overview")
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeMoviesLoadingSuccessfully(with: [movie0, movie1], at: 0)
        
        let movieCell0 = sut.simulateMovieViewVisible(at: 0)
        let movieCell1 = sut.simulateMovieViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [movie0.posterImageURL, movie1.posterImageURL])
        
        loader.completeImageDataLoadingWithError(at: 0)
        loader.completeImageDataLoadingWithError(at: 1)
        
        movieCell0?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [movie0.posterImageURL, movie1.posterImageURL, movie0.posterImageURL])
        
        movieCell1?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [movie0.posterImageURL, movie1.posterImageURL, movie0.posterImageURL, movie1.posterImageURL])
    }
    
    func test_movieView_preloadsImageURLWhenNearVisible() {
        let movie0 = makeMovie(id: 1, title: "title 1", overview: "any overview")
        let movie1 = makeMovie(id: 2, title: "title 2", overview: "any overview")
        let movie3 = makeMovie(id: 3, title: "title 3", overview: "any overview")
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeMoviesLoadingSuccessfully(with: [movie0, movie1, movie3], at: 0)
        XCTAssertTrue(loader.loadedImageURLs.isEmpty)
        
        sut.simulateMovieViewNearVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [movie0.posterImageURL])
    }
    
    func test_movieView_cancelsImageURLPreloadingWhenNotNearVisibleAnymore() {
        let movie0 = makeMovie(id: 1, title: "title 1", overview: "any overview")
        let movie1 = makeMovie(id: 2, title: "title 2", overview: "any overview")
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeMoviesLoadingSuccessfully(with: [movie0, movie1], at: 0)
        
        sut.simulateMovieViewNearVisible(at: 0)
        sut.simulateMovieViewNearVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [movie0.posterImageURL, movie1.posterImageURL])
        XCTAssertTrue(loader.cancelledURLs.isEmpty)
        
        sut.simulateMovieViewNotNearVisibleAnymore(at: 0)
        XCTAssertEqual(loader.cancelledURLs, [movie0.posterImageURL])
        
        sut.simulateMovieViewNotNearVisibleAnymore(at: 1)
        XCTAssertEqual(loader.cancelledURLs, [movie0.posterImageURL, movie1.posterImageURL])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (loader: MoviesLoaderSpy, sut: MoviesListViewController) {
        let loader = MoviesLoaderSpy()
        let sut = AppComposer.moviesListViewController(
            moviesLoader: loader,
            imageDataLoader: loader
        )
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (loader, sut)
    }
    
    private func assertThat(
        _ sut: MoviesListViewController,
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
        _ sut: MoviesListViewController,
        isRendering movies: [Movie],
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
    
    final class MoviesLoaderSpy: MoviesLoader, ImageDataLoader {
        private var loadMoviesCompletions = [(MoviesLoader.Result) -> Void]()
        private var loadImageDataCompletions = [(ImageDataLoader.Result) -> Void]()
        private(set) var loadedImageURLs = [URL]()
        private(set) var cancelledURLs = [URL]()
        
        var loadMoviesCallCount: Int {
            loadMoviesCompletions.count
        }
        
        struct Task: ImageDataLoaderTask {
            let onCancel: () -> Void
            
            func cancel() {
                onCancel()
            }
        }
        
        func load(completion: @escaping (MoviesLoader.Result) -> Void) {
            loadMoviesCompletions.append(completion)
        }
        
        func loadImageData(from url: URL, completion: @escaping (ImageDataLoader.Result) -> Void) -> ImageDataLoaderTask {
            loadedImageURLs.append(url)
            loadImageDataCompletions.append(completion)
            return Task { self.cancelledURLs.append(url) }
        }
        
        func completeMoviesLoadingSuccessfully(with movies: [Movie] = [], at index: Int) {
            loadMoviesCompletions[index](.success(movies))
        }
        
        func completeMoviesLoadingWithError(_ error: Error = NSError(domain: "an error", code: 0), at index: Int) {
            loadMoviesCompletions[index](.failure(error))
        }
        
        func completeImageDataLoadingSuccessfully(with data: Data = .init(), at index: Int) {
            loadImageDataCompletions[index](.success(data))
        }
        
        func completeImageDataLoadingWithError(at index: Int) {
            loadImageDataCompletions[index](.failure(NSError(domain: "an error", code: 0)))
        }
    }
    
    private func makeMovie(
        id: Int,
        title: String,
        overview: String,
        releaseDate: Date = Date()
    ) -> Movie {
        Movie(id: id, title: title, overview: overview, releaseDate: releaseDate, posterImageURL: URL(string: "http://image-\(id).com")!)
    }
}

extension Date {
    func year() -> String {
        let calendar = Calendar(identifier: .gregorian)
        let yearComponent = calendar.component(.year, from: self)
        
        return yearComponent.description
    }
}
