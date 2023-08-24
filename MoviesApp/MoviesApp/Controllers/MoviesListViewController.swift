
import UIKit
import MoviesCore

public final class MoviesListViewController: UITableViewController {
    
    private let moviesLoader: MoviesLoader
    private let imageDataLoader: ImageDataLoader
    private var imageDataLoaderTasks = [IndexPath: ImageDataLoaderTask]()
    private var models = [Movie]()
    
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
                self?.models = movies
                self?.tableView.reloadData()
        
            case .failure:
                break
            }
            
            self?.refreshControl?.endRefreshing()
        }
    }
}

// MARK: - UITableViewDataSource

extension MoviesListViewController {
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = MovieCell()
        cell.titleLabel.text = model.title
        cell.overviewLabel.text = model.overview
        cell.releaseDateLabel.text = model.releaseDate.year()
        cell.posterImageContainer.startShimmering()
        cell.retryButton.isHidden = true
        loadImageData(url: model.posterImageURL, forCell: cell, at: indexPath)
        cell.onRetry = { [weak self] in
            self?.loadImageData(url: model.posterImageURL, forCell: cell, at: indexPath)
        }
        
        return cell
    }
    
    private func loadImageData(url: URL, forCell cell: MovieCell, at indexPath: IndexPath) {
        imageDataLoaderTasks[indexPath] = imageDataLoader.loadImageData(from: url) { [weak cell] result in
            switch result {
            case .success(let data):
                let img = UIImage(data: data)
                cell?.posterImageView.image = img
                cell?.retryButton.isHidden = img != nil
            case .failure:
                cell?.retryButton.isHidden = false
            }
            
            cell?.posterImageContainer.stopShimmering()
        }
    }
}

// MARK: - UITableViewDataSourcePrefetching

extension MoviesListViewController: UITableViewDataSourcePrefetching {
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let movie = models[indexPath.row]
             imageDataLoaderTasks[indexPath] = imageDataLoader.loadImageData(from: movie.posterImageURL) { _ in
                
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            imageDataLoaderTasks[indexPath]?.cancel()
            imageDataLoaderTasks[indexPath] = nil
        }
    }
}

// MARK: - UITableViewDelegate

extension MoviesListViewController {
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        imageDataLoaderTasks[indexPath]?.cancel()
    }
}

extension Date {
    func year() -> String {
        let calendar = Calendar(identifier: .gregorian)
        let yearComponent = calendar.component(.year, from: self)
        
        return yearComponent.description
    }
}
