

import CoreData

public final class CoreDataMoviesStore: MoviesStore {
    
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
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        let context = self.context
        context.perform {
            let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
            request.returnsObjectsAsFaults = false
            
            do {
                guard let cache = try context.fetch(request).first else {
                    completion(.success([]))
                    return
                }
                let movies: [Movie] = cache.movies.compactMap { element in
                    guard let managedMovie = element as? ManagedMovie else {
                        return nil
                    }
                    let movie = Movie(
                        id: managedMovie.id,
                        title: managedMovie.title,
                        overview: managedMovie.overview,
                        releaseDate: managedMovie.releaseDate,
                        posterImageURL: managedMovie.posterImageURL
                    )
                    
                    return movie
                }
                completion(.success(movies))
                
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
