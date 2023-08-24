
import UIKit

public final class MovieCell: UITableViewCell {
    public let titleLabel = UILabel()
    public let overviewLabel = UILabel()
    public let releaseDateLabel = UILabel()
    public let posterImageContainer = UIView()
    public let posterImageView = UIImageView()
    public private(set) lazy var retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var onRetry: (() -> Void)?
    
    @objc
    private func retryButtonTapped() {
        onRetry?()
    }
}
