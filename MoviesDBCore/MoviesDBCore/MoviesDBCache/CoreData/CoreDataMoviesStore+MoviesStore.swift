

import CoreData

extension CoreDataMoviesStore: MoviesStore {
    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            completion(Result {
                try ManagedCache.find(in: context).map { managedCache in
                    let movies = managedCache.movies.compactMap { $0 as? ManagedMovie }.map(\.movie)
                    return Cache(movies, managedCache.timestamp)
                }
            })
        }
    }
    
    public func deleteCachedMovies(completion: @escaping DeletionCompletion) {
        completion(.success(()))
    }
    
    public func insert(_ movies: [Movie], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            completion(Result {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.movies = ManagedMovie.managedMovieOrderSet(from: movies, in: context)
                managedCache.timestamp = timestamp
                
                try context.save()
            })
        }
    }
}

