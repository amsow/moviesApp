

import CoreData

public final class CoreDataMoviesStore {
    
    private static let modelName = "MoviesStore"
    private static let model = NSManagedObjectModel.makeWith(name: modelName, in: Bundle(for: CoreDataMoviesStore.self))
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    private enum StoreError: Error {
        case modelNotFound
        case failedToLoadPersistenceStore(Error)
    }
    
    public init(storeURL: URL) throws {
        guard let model = Self.model else {
            throw StoreError.modelNotFound
        }
        
        container = try NSPersistentContainer.load(name: Self.modelName, model: model, url: storeURL)
        context = container.newBackgroundContext()
    }
}

extension CoreDataMoviesStore: MoviesStore {
    public func retrieve(completion: @escaping RetrievalCompletion) {
        let context = self.context
        context.perform {
            let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
            request.returnsObjectsAsFaults = false
            
            do {
                let movies = try ManagedCache.find(in: context).map { cache in
                    cache.movies.compactMap { $0 as? ManagedMovie }.map(\.movie)
                }
                completion(.success(movies ?? []))
                
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func deleteCachedMovies(completion: @escaping DeletionCompletion) {
        
    }
    
    public func insert(_ movies: [Movie], completion: @escaping InsertionCompletion) {
        let context = self.context
        context.perform {
            do {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.movies = ManagedMovie.managedMovieOrderSet(from: movies, in: context)
                managedCache.timestamp = Date()
                
                try context.save()
                completion(.success(()))
                
            } catch {
                completion(.failure(error))
            }
        }
    }
}
