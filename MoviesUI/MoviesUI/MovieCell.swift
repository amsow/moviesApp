
import UIKit

final class MovieCell: UITableViewCell {

    @IBOutlet private(set) weak var titleLabel: UILabel!
    @IBOutlet private(set) weak var releaseDateLabel: UILabel!
    @IBOutlet private(set) weak var overviewLabel: UILabel!
    @IBOutlet private(set) weak var movieImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        movieImageView.alpha = 0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        movieImageView.alpha = 0
    }
     
    func fadeIn(_ image: UIImage?) {
        movieImageView.image = image
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0.3,
            animations: {
                self.movieImageView.alpha = 1
            })
    }
}
