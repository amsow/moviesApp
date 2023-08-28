
import Combine
import Foundation
import MoviesCore

protocol MoviesListViewControllerDelegate {
    func didRequestDetails(for movie: Movie)
}

public final class MoviesListViewModel {
    
    typealias Observer<P> = (P) -> Void
    private var cancellable: Cancellable?
    
    // MARK: - Output Observers
    
    var onLoading: Observer<Bool>?
    var onLoadSucceeded: Observer<[Movie]>?
    var onLoadFailed: Observer<String?>?
    
    // MARK: - Input
    
    private(set) var onSelectMovieAtIndex: Observer<Int>?
    
    var delegate: MoviesListViewControllerDelegate?
    
    // MARK: - Properties
    
    private let loader: () -> MoviesLoader.Publisher
    
    private var movies = [Movie]()
    
    static var moviesListTitle: String {
        return NSLocalizedString(
            "MOVIES_TITLE",
            tableName: "Movies",
            comment: "The title of movies list"
        )
    }
    
    private static var loadErrorMessage: String {
        return NSLocalizedString(
            "MOVIES_LOAD_ERROR",
            tableName: "Movies",
            comment: "The message to be shown when an error occurs while loading movies"
        )
    }
    
    
    // MARK: - Init
    
    init(loader: @escaping () -> MoviesLoader.Publisher) {
        self.loader = loader
        forwardMovieSelection()
    }
    
    func loadMovies() {
        onLoadFailed?(.none)
        onLoading?(true)
        cancellable = loader()
            .sink { [weak self] completion in
            self?.onLoading?(false)
            
            switch completion {
            case .finished:
                break
                
            case .failure:
                self?.onLoadFailed?(Self.loadErrorMessage)
            }
            
        } receiveValue: { [weak self] movies in
            self?.onLoadSucceeded?(movies)
            self?.movies = movies
        }
    }
    
    private func forwardMovieSelection() {
        onSelectMovieAtIndex = { [weak self] index in
            guard let self else { return }
            self.delegate?.didRequestDetails(for: movies[index])
        }
    }
}
