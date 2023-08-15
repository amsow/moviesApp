

import Foundation

public protocol MoviesStore {
    typealias Cache = (movies: [Movie], timestamp: Date)
    
    typealias DeletionResult = Result<Void, Error>
    typealias InsertionResult = Result<Void, Error>
    typealias RetrievalResult = Result<Cache?, Error>
    
    typealias DeletionCompletion = (DeletionResult) -> Void
    typealias InsertionCompletion = (InsertionResult) -> Void
    typealias RetrievalCompletion = (RetrievalResult) -> Void
    
    func deleteCachedMovies(completion: @escaping DeletionCompletion)
    func insert(_ movies: [Movie], timestamp: Date, completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}
