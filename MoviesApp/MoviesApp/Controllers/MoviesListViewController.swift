
import UIKit
import MoviesCore

final class MoviesListViewModel {
    
    typealias Observer<P> = (P) -> Void
    
    var onLoading: Observer<Bool>?
    var onLoadSucceeded: Observer<[Movie]>?
    var onLoadFailed: Observer<Error>?
    
    private let loader: MoviesLoader
    
    init(loader: MoviesLoader) {
        self.loader = loader
    }
    
    func loadMovies() {
        onLoading?(true)
        loader.load { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let movies):
               onLoadSucceeded?(movies)
        
            case .failure(let error):
                onLoadFailed?(error)
            }
            
            onLoading?(false)
        }
    }
}

public final class MoviesListViewController: UITableViewController {
    
    private let imageDataLoader: ImageDataLoader
    
    private var tableModels = [MovieCellController]() {
        didSet { tableView.reloadData() }
    }
    
    private let viewModel: MoviesListViewModel
    
    public init(moviesLoader: MoviesLoader, imageDataLoader: ImageDataLoader) {
        self.viewModel = MoviesListViewModel(loader: moviesLoader)
        self.imageDataLoader = imageDataLoader
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        tableView.prefetchDataSource = self
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadMovies), for: .valueChanged)
        bindViewModel()
        loadMovies()
    }
    
    //MARK: - Private
    
    @objc
    private func loadMovies() {
        viewModel.loadMovies()
    }
    
    private func bindViewModel() {
        viewModel.onLoading = { [ weak self] isLoading in
            isLoading ? self?.refreshControl?.beginRefreshing() : self?.refreshControl?.endRefreshing()
        }
        
        viewModel.onLoadSucceeded = { [weak self] movies in
            guard let self else { return }
            tableModels = AppComposer.moviesCellControllers(for: movies, imageDataLoader: imageDataLoader)
        }
        
        viewModel.onLoadFailed = { _ in }
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
