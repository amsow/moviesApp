

import CoreData

public final class CoreDataMoviesStore {
    
    private static let modelName = "MoviesStore"
    private static let model = NSManagedObjectModel.makeWith(name: modelName, in: Bundle.module)
    
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
    
    func perform(action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
    
    private func cleanUpReferencesToPersistenceStores() {
        context.performAndWait {
            let coordinator = context.persistentStoreCoordinator
            try? coordinator?.persistentStores.forEach { try coordinator?.remove($0) }
        }
    }
    
    deinit {
        cleanUpReferencesToPersistenceStores()
    }
}
