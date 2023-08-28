
import Foundation
import MoviesCore

final class MovieDetailsViewModel {
    
    private let model: Movie
    
    var movieTitle: String? {
        model.title
    }
    
    var movieReleaseDate: String? {
        model.releaseDate?.year()
    }
    
    var movieOverview: String? {
        model.overview
    }
    
    init(model: Movie) {
        self.model = model
    }
}

final class DefaultMoviePosterImageRepository: MoviePosterImageRepository {
    
    private let store: ImageDataStore
    private let loader: ImageDataLoader
    
    init(store: ImageDataStore, loader: ImageDataLoader) {
        self.store = store
        self.loader = loader
    }
    
    func getImageData(for url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        store.retrieveData(for: url) { [weak self] result in
            if case .success(let data) = result, data != nil {
                completion(.success(data!))
            } else {
                let task = self?.loader.loadImageData(from: url, completion: completion)
            }
        }
    }
}
