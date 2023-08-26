
import MoviesCore

final class MoviesListViewModel {
    
    typealias Observer<P> = (P) -> Void
    
    // MARK: - Output Observers
    
    var onLoading: Observer<Bool>?
    var onLoadSucceeded: Observer<[Movie]>?
    var onLoadFailed: Observer<String?>?
    
    // MARK: - Properties
    
    private let loader: MoviesLoader
    
    private var loadErrorMessage: String {
        return "Something went wrong. Please try again later!"
    }
    
    
    // MARK: - Init
    
    init(loader: MoviesLoader) {
        self.loader = loader
    }
    
    func loadMovies() {
        onLoadFailed?(.none)
        onLoading?(true)
        loader.load { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let movies):
               onLoadSucceeded?(movies)
        
            case .failure:
                onLoadFailed?(loadErrorMessage)
            }
            
            onLoading?(false)
        }
    }
}
