
import Foundation

public final class LocalMoviesLoader {
    
    private let store: MoviesStore
    private let date: () -> Date
    
    public init(store: MoviesStore, date: @escaping () -> Date) {
        self.store = store
        self.date = date
    }
}

// MARK: - MoviesCache

extension LocalMoviesLoader: MoviesCache {
    
    public func save(_ movies: [Movie], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedMovies { [weak self] deletionResult in
            guard let self = self else { return }
            switch deletionResult {
            case .success:
                self.cache(movies, with: completion)
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func cache(_ movies: [Movie], with completion: @escaping (SaveResult) -> Void) {
        self.store.insert(movies, timestamp: date()) { [weak self] insertionResult in
            guard self != nil else { return }
            if case .failure(let error) = insertionResult {
                completion(.failure(error))
            } else {
                completion(insertionResult)
            }
        }
    }
}

// MARK: - MoviesLoader

extension LocalMoviesLoader: MoviesLoader {
    public func load(completion: @escaping (Result<[Movie], Error>) -> Void) {
        store.retrieve { [weak self] result in
            guard self != nil else { return }
            switch result {
            case .failure(let error):
                completion(.failure(error))
                
            case .success(let .some(cache)):
                completion(.success(cache.movies))
                
            case .success:
                completion(.success([]))
            }
        }
    }
}
