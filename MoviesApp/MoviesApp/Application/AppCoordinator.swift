
import UIKit
import MoviesCore

protocol Coordinator {
    func start()
}

final class AppCoordinator {
    
    typealias Dependencies = MoviePosterImageRepositoryProvider
    
    var navigationController: UINavigationController?
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
}

// MARK: - MoviesListViewControllerDelegate

extension AppCoordinator: MoviesListViewControllerDelegate {
    func didRequestDetails(for movie: Movie) {
        let detailsViewController = AppComposer.makeMovieDetailsViewControllerWith(
            movie: movie,
            posterImageRepository: dependencies.posterImageDataRepository
        )
        
        navigationController?.pushViewController(detailsViewController, animated: true)
    }
}
