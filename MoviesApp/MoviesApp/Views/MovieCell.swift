
import UIKit

public final class MovieCell: UITableViewCell {
    @IBOutlet public private(set) weak var titleLabel: UILabel!
    @IBOutlet public private(set) weak var overviewLabel: UILabel!
    @IBOutlet public private(set) weak var releaseDateLabel: UILabel!
    @IBOutlet public private(set) weak var posterImageContainer: UIView!
    @IBOutlet public private(set) weak var posterImageView: UIImageView!
    @IBOutlet public private(set) weak var retryButton: UIButton!
    
    var onRetry: (() -> Void)?
    
    @IBAction
    private func retryButtonTapped() {
        onRetry?()
    }
}
