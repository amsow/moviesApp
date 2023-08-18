
import UIKit

final class MoviesViewController: UITableViewController {
    
    private var movies = [MovieViewModel]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
        tableView.setContentOffset(
            CGPoint(x: 0, y: -tableView.contentInset.top),
            animated: false
        )
    }
    
    @IBAction func refresh() {
        refreshControl?.beginRefreshing()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if self.movies.isEmpty {
                self.movies = MovieViewModel.sample
                self.tableView.reloadData()
            }
            self.refreshControl?.endRefreshing()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let movie = movies[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell") as! MovieCell
        cell.configure(with: movie)
        
        return cell
    }
}

extension MovieCell {
    fileprivate func configure(with model: MovieViewModel) {
        titleLabel.text = model.title
        releaseDateLabel.text = model.date
        overviewLabel.text = model.overview
        fadeIn(UIImage(named: model.imageName))
    }
}
