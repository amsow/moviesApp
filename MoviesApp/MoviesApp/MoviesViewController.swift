
import UIKit
import MoviesCore

public final class MoviesViewController: UITableViewController {
    
    private let loader: MoviesLoader
    
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
        loader.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}
