
import Foundation

public final class DefaultMoviePosterImageRepository: MoviePosterImageRepository {
    
    private let store: ImageDataStore
    private let loader: ImageDataLoader
    
    public init(store: ImageDataStore, loader: ImageDataLoader) {
        self.store = store
        self.loader = loader
    }
    
    public func getImageData(for url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        store.retrieveData(for: url) { [weak self] result in
            if case .success(let data) = result, data != nil {
                completion(.success(data!))
            } else {
                _ = self?.loader.loadImageData(from: url, completion: completion)
            }
        }
    }
}
