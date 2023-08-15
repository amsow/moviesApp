

import CoreData

extension CoreDataMoviesStore: MoviesStore {
    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
            request.returnsObjectsAsFaults = false
            
            do {
                let managedCache = try ManagedCache.find(in: context)
                let movies = managedCache.map { cache in
                    cache.movies.compactMap { $0 as? ManagedMovie }.map(\.movie)
                }
                
                managedCache == nil ? completion(.success(nil)) : completion(.success(Cache(movies: movies!, timestamp: managedCache!.timestamp)))
                
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func deleteCachedMovies(completion: @escaping DeletionCompletion) {
        
    }
    
    public func insert(_ movies: [Movie], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            do {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.movies = ManagedMovie.managedMovieOrderSet(from: movies, in: context)
                managedCache.timestamp = timestamp
                
                try context.save()
                completion(.success(()))
                
            } catch {
                completion(.failure(error))
            }
        }
    }
}

