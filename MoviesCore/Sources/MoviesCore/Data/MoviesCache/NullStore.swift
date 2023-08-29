

import Foundation

public final class NullStore: MoviesStore, ImageDataStore {
    
    public init() {}
    
    public func deleteCachedMovies(completion: @escaping DeletionCompletion) {}
    
    public func insert(_ movies: [Movie], timestamp: Date, completion: @escaping InsertionCompletion) {}
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.success(.none))
    }
    
    public func retrieveData(for url: URL, completion: @escaping (ImageDataStore.RetrievalResult) -> Void) {
        completion(.success(.none))
    }
    
    public func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) { }
}
