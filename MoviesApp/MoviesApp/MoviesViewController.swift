
import UIKit
import MoviesCore

public final class MoviesViewController: UITableViewController {
    
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

extension MoviesViewController {
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
        imageDataLoaderTasks[indexPath] = imageDataLoader.loadImageData(from: model.posterImageURL) { [weak cell] _ in
            cell?.posterImageContainer.stopShimmering()
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension MoviesViewController {
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
