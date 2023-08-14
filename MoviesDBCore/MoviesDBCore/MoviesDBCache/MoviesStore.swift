

import Foundation

public protocol MoviesStore {
    typealias DeletionResult = Result<Void, Error>
    typealias InsertionResult = Result<Void, Error>
    typealias RetrievalResult = Result<[Movie], Error>
    
    typealias DeletionCompletion = (DeletionResult) -> Void
    typealias InsertionCompletion = (InsertionResult) -> Void
    typealias RetrievalCompletion = (RetrievalResult) -> Void
    
    func deleteCachedMovies(completion: @escaping DeletionCompletion)
    func insert(_ movies: [Movie], completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}
