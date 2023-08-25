
import UIKit
import MoviesCore

public final class MoviesListViewController: UITableViewController {
    
    private let moviesLoader: MoviesLoader
    private let imageDataLoader: ImageDataLoader
    
    private var tableModels = [MovieCellController]() {
        didSet { tableView.reloadData() }
    }
    
    public init(moviesLoader: MoviesLoader, imageDataLoader: ImageDataLoader) {
        self.moviesLoader = moviesLoader
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
        loadMovies()
    }
    
    @objc
    private func loadMovies() {
        refreshControl?.beginRefreshing()
        moviesLoader.load { [weak self] result in
            switch result {
            case .success(let movies):
                self?.mapCellControllers(for: movies)
        
            case .failure:
                break
            }
            
            self?.refreshControl?.endRefreshing()
        }
    }
    
    private func mapCellControllers(for movies: [Movie]) {
        tableModels = movies.map { movie in
            let adapter = MoviePosterImageDataLoaderPresentationAdapter<MovieCellController, UIImage>(model: movie, imageDataLoader: imageDataLoader)
            let controller = MovieCellController(delegate: adapter)
            adapter.presenter = MovieCellPresenter(view: controller, imageTransformer: UIImage.init)
            
            return controller
        }
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

extension Date {
    func year() -> String {
        let calendar = Calendar(identifier: .gregorian)
        let yearComponent = calendar.component(.year, from: self)
        
        return yearComponent.description
    }
}
