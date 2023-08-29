

import XCTest
import MoviesCore
@testable import MoviesApp

final class MoviesListSnapshotTests: XCTestCase {

    func test_emptyMoviesList() {
        let sut = makeSUT()
        
        sut.displayWithEmptyMovies()
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), record: true, named: "EMPTY_MOVIES_LIST_LIGHT")
    }
    
    func test_moviesListWithContent() {
        let sut = makeSUT()
        
        sut.displayMoviesListWithContent()
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), record: true, named: "MOVIES_LIST_WITH_CONTENT_LIGHT")
    }
    
    // TODO: - To be fixed as the frame of time is very low to capture the forwarded event by the viewModel
    func _test_moviesListWithError() {
        let sut = makeSUT()
        
        sut.displayMoviesListWithError("An error occured. Please try again")
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), record: true, named: "MOVIES_LIST_ERROR_LIGHT")
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> MoviesListViewController {
        let bundle = Bundle(for: MoviesListViewController.self)
        let storyboard = UIStoryboard(name: "MoviesScene", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! MoviesListViewController
        controller.loadViewIfNeeded()
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        return controller
    }
    
    
    func assert(snapshot: UIImage, record isRecording: Bool, named name: String, file: StaticString = #file, line: UInt = #line) {
       let snapshotURL = makeSnapshotURL(named: name, file: file)
       let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)
        
        if isRecording {
            record(snapshot: snapshot, named: name, file: file, line: line)
        }
       
       guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
           XCTFail("Failed to load store snapshot at URL: \(snapshotURL). Use the `record` method to store a snapshot before asserting.", file: file, line: line)
           return
       }
       
       if storedSnapshotData != snapshotData {
           let temporarySnapshotURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
               .appendingPathComponent(snapshotURL.lastPathComponent)
           
           try? snapshotData?.write(to: temporarySnapshotURL)
           
           XCTFail("New snapshot does not match stored snapshot. New snapshot URL: \(temporarySnapshotURL), stored snapshot URL: \(snapshotURL)", file: file, line: line)
       }
   }
   
   private func record(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
       let snapshotURL = makeSnapshotURL(named: name, file: file)
       let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)
       
       do {
           try FileManager.default.createDirectory(
               at: snapshotURL.deletingLastPathComponent(),
               withIntermediateDirectories: true
           )
           
           try snapshotData?.write(to: snapshotURL)
       } catch {
           XCTFail("Failed to record snapshot with error \(error)", file: file, line: line)
       }
   }
    
    private func makeSnapshotURL(named name: String, file: StaticString) -> URL {
        let snapshotURL = URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("__Snapshots__")
            .appendingPathComponent("\(name).png")
        
        return snapshotURL
    }
    
    private func makeSnapshotData(for snapshot: UIImage, file: StaticString, line: UInt) -> Data? {
        guard let snapshotData = snapshot.pngData() else {
            XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
            return nil
        }
        return snapshotData
    }
}

extension MoviesListViewController {
    func displayWithEmptyMovies() {
        display([])
    }
    
    func displayMoviesListWithContent() {
        let cellstubs = [
           MovieCellControllerStub(
            title: "Black Panther",
            overview: "Black panther full description",
            releaseDate: "2019",
            isLoading: false,
            image: UIImage.makeWithColor(.red)
           ),
           MovieCellControllerStub(
            title: "Casa De Papel",
            overview: "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum",
            releaseDate: "2019",
            isLoading: false,
            image: UIImage.makeWithColor(.green)
           ),
           MovieCellControllerStub(
            title: "Glory",
            overview: "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
            releaseDate: "2000",
            isLoading: false,
            image: UIImage.makeWithColor(.yellow)
           ),
           MovieCellControllerStub(
            title: "les 100",
            overview: "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type",
            releaseDate: "1998",
            isLoading: false,
            image: UIImage.makeWithColor(.purple)
           )
        ]
        
        display(cellstubs.map { stub in
            let cellController = MovieCellController(delegate: stub)
            stub.controller = cellController
            return cellController
        })
    }
    
    func displayMoviesListWithError(_ message: String) {
        class dummyLoader: MoviesLoader {
            func load(completion: @escaping (MoviesLoader.Result) -> Void) {}
        }
        
        viewModel = MoviesListViewModel(loader: dummyLoader().loadPublisher)
        
        
        viewModel?.onLoadFailed?(message)
    }
}

final class MovieCellControllerStub: MovieCellControllerDelegate {
    
    let viewModel: MovieViewModel<UIImage>
    
    weak var controller: MovieCellController?
    
     init(
        title: String,
        overview: String,
        releaseDate: String?,
        isLoading: Bool,
        image: UIImage?
    ) {
       viewModel = MovieViewModel(
        title: title,
        overview: overview,
        releaseDate: releaseDate,
        posterImage: image,
        isLoading: isLoading,
        shouldRetry: image == nil)
    }
    
    func didRequestImageDataLoading() {
        controller?.display(viewModel)
    }
    
    func didCancelImageDataLoadingRequest() {}
    
}
