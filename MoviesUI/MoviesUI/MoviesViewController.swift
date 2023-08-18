
import UIKit

final class MoviesViewController: UITableViewController {
    
    private let movies = MovieViewModel.sample
    
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
        movieImageView.image = UIImage(named: model.imageName)
    }
}
