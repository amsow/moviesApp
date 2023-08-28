
import UIKit

final class MovieDetailsView: UIView {
    
   // MARK: - Properties
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    private let releaseDateLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let fullOverviewLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    private let movieImageView: UIImageView = {
        let imgView = UIImageView()
        return imgView
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        return scrollView
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        addConstraints()
    }
    
    // MARK: - View Setup
    
    private func setupView() {
        [
            movieImageView,
            titleLabel,
            releaseDateLabel,
            fullOverviewLabel
        ].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(view)
        }
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        
        backgroundColor = .white
    }
    
    private func addConstraints() {
        let imageViewLayoutConsttraints = [
            movieImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            movieImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            movieImageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            movieImageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 8),
            movieImageView.heightAnchor.constraint(equalToConstant: 500)
        ]
        
        let titleLabelLayoutConsttraints = [
            titleLabel.leadingAnchor.constraint(equalTo: movieImageView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: movieImageView.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: releaseDateLabel.topAnchor, constant: -8)
        ]
        
        let releaseDateLabelLayoutConsttraints = [
            releaseDateLabel.leadingAnchor.constraint(equalTo: movieImageView.leadingAnchor),
            releaseDateLabel.trailingAnchor.constraint(equalTo: movieImageView.trailingAnchor),
            releaseDateLabel.bottomAnchor.constraint(equalTo: fullOverviewLabel.topAnchor, constant: -8)
        ]
        
        let overviewLabelLayoutConsttraints = [
            fullOverviewLabel.leadingAnchor.constraint(equalTo: movieImageView.leadingAnchor),
            fullOverviewLabel.trailingAnchor.constraint(equalTo: movieImageView.trailingAnchor),
            fullOverviewLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -30)
        ]
        
        let scrollViewLayoutConsttraints = [
            scrollView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ]
        
         [
           imageViewLayoutConsttraints,
           titleLabelLayoutConsttraints,
           releaseDateLabelLayoutConsttraints,
           overviewLabelLayoutConsttraints,
           scrollViewLayoutConsttraints
         ].forEach(NSLayoutConstraint.activate)
    }
}
