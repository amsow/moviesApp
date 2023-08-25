
import UIKit
import MoviesCore

public final class MoviesListViewController: UITableViewController {
    
    private var tableModels = [MovieCellController]() {
        didSet { tableView.reloadData() }
    }
    
    private let cellControllerFactory: MovieCellControllerFactory
    private let viewModel: MoviesListViewModel
    
    init(viewModel: MoviesListViewModel, cellControllerFactory: MovieCellControllerFactory) {
        self.viewModel = viewModel
        self.cellControllerFactory = cellControllerFactory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        tableView.prefetchDataSource = self
        refreshControl = UIRefreshControl()
        bindViewModel()
        loadMovies()
    }
    
    //MARK: - Private
    
    @objc
    private func loadMovies() {
        viewModel.loadMovies()
    }
    
    private func bindViewModel() {
        viewModel.onLoading = { [ weak self] isLoading in self?.updateLoadingState(isLoading) }
        
        viewModel.onLoadSucceeded = { [weak self] movies in self?.updateTable(with: movies) }
        
        viewModel.onLoadFailed = { _ in }
        
        refreshControl?.addTarget(self, action: #selector(loadMovies), for: .valueChanged)
    }
    
    private func updateTable(with movies: [Movie]) {
        tableModels = movies.map(cellControllerFactory.makeCellController)
    }
    
    private func updateLoadingState(_ isLoading: Bool) {
        isLoading ? refreshControl?.beginRefreshing() : refreshControl?.endRefreshing()
    }
}

// MARK: - UITableViewDataSource

extension MoviesListViewController {
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModels.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          
        guard let cellController = movieCellController(at: indexPath), let cell = cellController.view() else {
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
