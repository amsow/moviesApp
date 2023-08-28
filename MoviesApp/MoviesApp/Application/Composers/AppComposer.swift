
import Combine
import MoviesCore
import UIKit

public final class AppComposer {
    
    public static func moviesListViewControllerWith(
        moviesLoader: @escaping () -> MoviesLoader.Publisher,
        imageDataLoader: @escaping (URL) -> ImageDataLoader.Publisher
    ) -> MoviesListViewController {
        let moviesListController = makeListViewController()
        moviesListController.viewModel = MoviesListViewModel(loader: moviesLoader().dispatchOnMainQueue)
        moviesListController.cellControllerFactory = MovieCellControllerFactory(
            imageDataLoader: { imageDataLoader($0).dispatchOnMainQueue()}
        )
        
        return moviesListController
    }
    
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

