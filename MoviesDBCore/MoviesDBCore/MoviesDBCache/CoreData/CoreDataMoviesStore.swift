

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
        completion(.success([]))
    }
    
    public func deleteCachedMovies(completion: @escaping DeletionCompletion) {
        
    }
    
    public func insert(_ movies: [MoviesDBCore.Movie], completion: @escaping InsertionCompletion) {
        
    }
}
