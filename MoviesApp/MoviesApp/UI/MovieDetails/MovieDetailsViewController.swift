

import UIKit

final class MovieDetailsViewController: UIViewController {
    
    private let mainView = MovieDetailsView()
    
    private let viewModel: MovieDetailsViewModel
    
    init(viewModel: MovieDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.movieImageView.startShimmering()
        viewModel.updatePosterImage()
    }
    
    private func bindViewModel() {
        mainView.titleLabel.text = viewModel.movieTitle
        mainView.releaseDateLabel.text = viewModel.movieReleaseDate
        mainView.fullOverviewLabel.text = viewModel.movieOverview
        
        viewModel.onPosterImageChange = { [weak self] imgData in
            self?.mainView.movieImageView.image = UIImage(data: imgData)
        }
    }
}