
import UIKit
import MoviesCore

public final class AppComposer {
    
    public static func moviesListViewController(moviesLoader: MoviesLoader, imageDataLoader: ImageDataLoader) -> MoviesListViewController {
        let controller = MoviesListViewController(moviesLoader: moviesLoader, imageDataLoader: imageDataLoader)
        
        return controller
    }
    
    static func moviesCellControllers(for movies: [Movie], imageDataLoader: ImageDataLoader) -> [MovieCellController] {
        let cellControllers = movies.map { movie in
            let adapter = MoviePosterImageDataLoaderPresentationAdapter<WeakReferenceProxy<MovieCellController>, UIImage>(
                model: movie,
                imageDataLoader: imageDataLoader
            )
            let controller = MovieCellController(delegate: adapter)
            adapter.presenter = MovieCellPresenter(view: WeakReferenceProxy(controller), imageTransformer: UIImage.init)
            
            return controller
        }
        
        return cellControllers
    }
}
