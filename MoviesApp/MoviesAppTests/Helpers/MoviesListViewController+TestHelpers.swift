

import MoviesApp
import UIKit

extension MoviesListViewController {
    private var section: Int { return 0 }
    
    func simulateUserInitiatedMoviesReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    @discardableResult
    func simulateMovieViewVisible(at index: Int) -> MovieCell? {
        return movieCell(at: index) as? MovieCell
    }
    
    func simulateMovieViewNearVisible(at index: Int) {
        let datasource = tableView.prefetchDataSource
        datasource?.tableView(tableView, prefetchRowsAt: [IndexPath(row: index, section: 0)])
    }
    
    func simulateMovieViewNotNearVisibleAnymore(at index: Int) {
        let datasource = tableView.prefetchDataSource
        datasource?.tableView?(tableView, cancelPrefetchingForRowsAt: [IndexPath(row: index, section: section)])
    }
    
    func simulateMovieViewNotVisible(at index: Int) {
        let delegate = tableView.delegate
        guard let cell = simulateMovieViewVisible(at: index) else { return }
        delegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: IndexPath(row: index, section: section))
    }
    
    func isShowingLoadingIndicator() -> Bool {
        refreshControl?.isRefreshing == true
    }
    
    func numberOfRenderedMovieViews() -> Int {
        tableView.numberOfRows(inSection: section)
    }
    
    func movieCell(at row: Int) -> UITableViewCell? {
        let datasource = tableView.dataSource
       return datasource?.tableView(tableView, cellForRowAt: IndexPath(row: row, section: section))
    }
}
