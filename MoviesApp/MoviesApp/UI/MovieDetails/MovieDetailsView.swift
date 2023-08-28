
import UIKit

final class MovieDetailsView: UIView {
    
   // MARK: - Properties
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.numberOfLines = 0
        return label
    }()
    
    let releaseDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        return label
    }()
    
    let fullOverviewLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    let movieImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        return imgView
    }()
    
    let imageViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 227/255, green: 227/255, blue: 227/255, alpha: 1)
        view.layer.cornerRadius = 20
        view.mask?.clipsToBounds = true
        return view
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
            imageViewContainer,
            titleLabel,
            releaseDateLabel,
            fullOverviewLabel
        ].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(view)
        }
        movieImageView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        imageViewContainer.addSubview(movieImageView)
        addSubview(scrollView)
        
        backgroundColor = .white
    }
    
    private func addConstraints() {
        let imageViewLayoutConsttraints = [
            imageViewContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            imageViewContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            imageViewContainer.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            imageViewContainer.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -10),
            imageViewContainer.heightAnchor.constraint(equalToConstant: 400),
            
            movieImageView.leadingAnchor.constraint(equalTo: imageViewContainer.leadingAnchor),
            movieImageView.trailingAnchor.constraint(equalTo: imageViewContainer.trailingAnchor),
            movieImageView.topAnchor.constraint(equalTo: imageViewContainer.topAnchor),
            movieImageView.bottomAnchor.constraint(equalTo: imageViewContainer.bottomAnchor)
        ]
        
        let titleLabelLayoutConsttraints = [
            titleLabel.topAnchor.constraint(equalTo: imageViewContainer.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: imageViewContainer.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: imageViewContainer.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: releaseDateLabel.topAnchor, constant: -8)
        ]
        
        let releaseDateLabelLayoutConsttraints = [
            releaseDateLabel.leadingAnchor.constraint(equalTo: imageViewContainer.leadingAnchor),
            releaseDateLabel.trailingAnchor.constraint(equalTo: imageViewContainer.trailingAnchor),
            releaseDateLabel.bottomAnchor.constraint(equalTo: fullOverviewLabel.topAnchor, constant: -8)
        ]
        
        let overviewLabelLayoutConsttraints = [
            fullOverviewLabel.leadingAnchor.constraint(equalTo: imageViewContainer.leadingAnchor),
            fullOverviewLabel.trailingAnchor.constraint(equalTo: imageViewContainer.trailingAnchor),
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
