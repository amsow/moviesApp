
import UIKit
import MoviesCore

public final class MoviesViewController: UITableViewController {
    
    private let loader: MoviesLoader
    private var models = [Movie]()
    
    public init(loader: MoviesLoader) {
        self.loader = loader
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
        loader.load { [weak self] result in
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
        
        return cell
    }
}

extension Date {
    func year() -> String {
        let calendar = Calendar(identifier: .gregorian)
        let yearComponent = calendar.component(.year, from: self)
        
        return yearComponent.description
    }
}
