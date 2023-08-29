

import XCTest
@testable import MoviesApp

final class MoviesListSnapshotTests: XCTestCase {

    func test_emptyMoviesList() {
        let sut = makeSUT()
        
        sut.displayWithEmptyMovies()
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), record: false, named: "EMPTY_MOVIES_LIST_LIGHT")
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
        viewModel?.onLoadSucceeded?([])
    }
}
