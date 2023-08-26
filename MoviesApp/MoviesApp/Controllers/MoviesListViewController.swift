
import UIKit

public final class MoviesListViewController: UITableViewController {
    
    public let errorView = UILabel()
    
    private var tableModels = [MovieCellController]() {
        didSet { tableView.reloadData() }
    }
    
    var cellControllerFactory: MovieCellControllerFactory?
    var viewModel: MoviesListViewModel?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        tableView.prefetchDataSource = self
        bindViewModel()
        refresh()
    }
    
    //MARK: - Private
    
    @IBAction
    private func refresh() {
        viewModel?.loadMovies()
    }
    
    private func bindViewModel() {
        
        viewModel?.onLoading = { [ weak self] isLoading in self?.updateLoadingState(isLoading) }
        
        viewModel?.onLoadSucceeded = { [weak self] movies in
            guard let self, let cellControllerFactory = cellControllerFactory else {
                return
            }
            tableModels = movies.map(cellControllerFactory.makeCellController)
        }
        
        viewModel?.onLoadFailed = { [weak self] errorMessage in self?.updateErrorState(errorMessage) }
        
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    private func updateLoadingState(_ isLoading: Bool) {
        isLoading ? refreshControl?.beginRefreshing() : refreshControl?.endRefreshing()
    }
    
    private func updateErrorState(_ message: String?) {
        errorView.text = message
    }
}

// MARK: - UITableViewDataSource

extension MoviesListViewController {
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModels.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cellController = movieCellController(at: indexPath), let cell = cellController.view(in: tableView) else {
            assertionFailure("Unable to create \(MovieCell.self)")
            return UITableViewCell()
        }
        
        return cell
    }
    
    private func movieCellController(at indexPath: IndexPath) -> MovieCellController? {
        guard indexPath.row < tableModels.count else {
            return nil
        }
        return tableModels[indexPath.row]
    }
}

// MARK: - UITableViewDataSourcePrefetching

extension MoviesListViewController: UITableViewDataSourcePrefetching {
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            movieCellController(at: indexPath)?.preloadImageData()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            movieCellController(at: indexPath)?.cancelImageDataLoadTask()
        }
    }
}

// MARK: - UITableViewDelegate

extension MoviesListViewController {
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        movieCellController(at: indexPath)?.cancelImageDataLoadTask()
    }
}
