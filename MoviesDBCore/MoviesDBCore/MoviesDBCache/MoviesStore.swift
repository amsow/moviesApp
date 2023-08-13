

import Foundation

public protocol MoviesStore {
    typealias DeletionResult = Result<Void, Error>
    typealias InsertionResult = Result<Void, Error>
    
    typealias DeletionCompletion = (DeletionResult) -> Void
    typealias InsertionCompletion = (InsertionResult) -> Void
    
    func deleteCachedMovies(completion: @escaping DeletionCompletion)
    func insert(_ movies: [Movie], completion: @escaping InsertionCompletion)
    func retrieve()
}
