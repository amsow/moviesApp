
import MoviesCore

final class MoviesListViewModel {
    
    typealias Observer<P> = (P) -> Void
    
    // MARK: - Output Observers
    
    var onLoading: Observer<Bool>?
    var onLoadSucceeded: Observer<[Movie]>?
    var onLoadFailed: Observer<Error>?
    
    // MARK: - Properties
    
    private let loader: MoviesLoader
    
    
    // MARK: - Init
    
    init(loader: MoviesLoader) {
        self.loader = loader
    }
    
    func loadMovies() {
        onLoading?(true)
        loader.load { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let movies):
               onLoadSucceeded?(movies)
        
            case .failure(let error):
                onLoadFailed?(error)
            }
            
            onLoading?(false)
        }
    }
}
