

import CoreData

public final class CoreDataMoviesStore: MoviesStore {
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL) {
        let model = NSManagedObjectModel()
        container = NSPersistentContainer(name: "MoviesStore", managedObjectModel: model)
        container.loadPersistentStores { _, _ in
            
        }
        context = container.newBackgroundContext()
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.success([]))
    }
    
    public func deleteCachedMovies(completion: @escaping DeletionCompletion) {
        
    }
    
    public func insert(_ movies: [MoviesDBCore.Movie], completion: @escaping InsertionCompletion) {
        
    }
}
