
import UIKit
import MoviesCore

public final class AppComposer {
    
    public static func moviesListViewController(moviesLoader: MoviesLoader, imageDataLoader: ImageDataLoader) -> MoviesListViewController {
        return makeListViewController(moviesLoader: moviesLoader, imageDataLoader: imageDataLoader)
    }
    
    private static func makeListViewController(moviesLoader: MoviesLoader, imageDataLoader: ImageDataLoader) -> MoviesListViewController {
        let storyboard = UIStoryboard(name: "MoviesScene", bundle: Bundle(for: MoviesListViewController.self))
        let controller = storyboard.instantiateInitialViewController() as! MoviesListViewController
        controller.viewModel = MoviesListViewModel(loader: moviesLoader)
        controller.cellControllerFactory = MovieCellControllerFactory(imageDataLoader: imageDataLoader)
        
        return controller
    }
}

final class MovieCellControllerFactory {
    
    private let imageDataLoader: ImageDataLoader
    
    init(imageDataLoader: ImageDataLoader) {
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

