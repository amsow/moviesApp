
import UIKit
import MoviesCore

public final class AppComposer {
    
    public static func moviesListViewController(moviesLoader: MoviesLoader, imageDataLoader: ImageDataLoader) -> MoviesListViewController {
        let viewModel = MoviesListViewModel(loader: moviesLoader)
        let cellControllerFactory = MovieCellControllerFactory(imageDataLoader: imageDataLoader)
        let controller = MoviesListViewController(viewModel: viewModel, cellControllerFactory: cellControllerFactory)
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

