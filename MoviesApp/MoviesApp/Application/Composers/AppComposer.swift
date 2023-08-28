
import Combine
import MoviesCore
import UIKit

public final class AppComposer {
    
    public static func moviesListViewControllerWith(
        moviesLoader: @escaping () -> MoviesLoader.Publisher,
        imageDataLoader: @escaping (URL) -> ImageDataLoader.Publisher,
        delegate: MoviesListViewControllerDelegate? = nil
    ) -> MoviesListViewController {
        let moviesListController = makeListViewController()
        let viewModel = MoviesListViewModel(loader: moviesLoader().dispatchOnMainQueue)
        viewModel.delegate = delegate
        moviesListController.viewModel = viewModel
        moviesListController.cellControllerFactory = MovieCellControllerFactory(
            imageDataLoader: { imageDataLoader($0).dispatchOnMainQueue()}
        )
        
        return moviesListController
    }
    
    static func makeMovieDetailsViewControllerWith(
        movie: Movie,
        posterImageRepository: MoviePosterImageRepository
    ) -> UIViewController {
        let viewModel = MovieDetailsViewModel(model: movie, posterImageRepository: posterImageRepository)
        let controller = MovieDetailsViewController(viewModel: viewModel)
        
        return controller
    }
    
    // MARK: - Private
    
    private static func makeListViewController() -> MoviesListViewController {
        let storyboard = UIStoryboard(name: "MoviesScene", bundle: Bundle(for: MoviesListViewController.self))
        let controller = storyboard.instantiateInitialViewController() as! MoviesListViewController
        controller.title = MoviesListViewModel.moviesListTitle
            
        return controller
    }
}

final class MovieCellControllerFactory {
    
    private let imageDataLoader: (URL) -> ImageDataLoader.Publisher
    
    init(imageDataLoader: @escaping (URL) -> ImageDataLoader.Publisher) {
        self.imageDataLoader = imageDataLoader
    }
    
    func makeCellController(for movie: Movie) -> MovieCellController {
        let adapter = MoviePosterImageDataLoaderPresentationAdapter<WeakReferenceProxy<MovieCellController>, UIImage>(
            model: movie,
            imageDataLoader: imageDataLoader
        )
        let controller = MovieCellController(delegate: adapter)
        adapter.presenter = MovieCellPresenter(view: WeakReferenceProxy(controller), imageTransformer: UIImage.init)
        
        return controller
    }
}

