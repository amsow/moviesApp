
import UIKit

final class MovieCell: UITableViewCell {

    @IBOutlet private(set) weak var titleLabel: UILabel!
    @IBOutlet private(set) weak var releaseDateLabel: UILabel!
    @IBOutlet private(set) weak var overviewLabel: UILabel!
    @IBOutlet private(set) weak var movieImageView: UIImageView!
    @IBOutlet private(set) weak var movieImageContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        movieImageView.alpha = 0
        movieImageContainer.startShimmering()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        movieImageView.alpha = 0
        movieImageContainer.startShimmering()
    }
     
    func fadeIn(_ image: UIImage?) {
        movieImageView.image = image
        
        UIView.animate(
            withDuration: 0.25,
            delay: 1.25,
            animations: {
                self.movieImageView.alpha = 1
            },
            completion: { completed in
                if completed {
                    self.movieImageContainer.stopShimmering()
                }
            }
        )
    }
}

extension MovieCell {
     func configure(with model: MovieViewModel) {
        titleLabel.text = model.title
        releaseDateLabel.text = model.date
        overviewLabel.text = model.overview
        fadeIn(UIImage(named: model.imageName))
    }
}

private extension UIView {
    
    private var shimmeringAnimationKey: String { "shimmer" }
    
    func startShimmering() {
        let white = UIColor.white.cgColor
        let alpha = UIColor.white.withAlphaComponent(0.7).cgColor
        
        let width = bounds.width
        let height = bounds.height
        
        let gradient = CAGradientLayer()
        gradient.colors = [alpha, white, alpha]
        gradient.startPoint = CGPoint(x: 0, y: 0.4)
        gradient.endPoint = CGPoint(x: 1, y: 0.6)
        gradient.locations = [0.4, 0.5, 0.6]
        gradient.frame = CGRect(x: -width, y: 0, width: width * 3, height: height)
        layer.mask = gradient
        
        let animation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.locations))
        animation.fromValue = [0.0, 0.1, 0.2]
        animation.toValue = [0.8, 0.9, 1.0]
        animation.duration = 1
        animation.repeatCount = .infinity
        gradient.add(animation, forKey: shimmeringAnimationKey)
    }
    
    func stopShimmering() {
        layer.mask = nil
    }
}
