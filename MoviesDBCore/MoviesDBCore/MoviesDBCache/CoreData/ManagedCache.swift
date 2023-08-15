

import CoreData

@objc(ManagedCache)
final class ManagedCache: NSManagedObject {
    /// The date when the cache has been made
    @NSManaged var timestamp: Date
    
    /// the set of movies cached
    @NSManaged var movies: NSOrderedSet
}

extension ManagedCache {
    static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
        request.returnsObjectsAsFaults = false
        
        return try context.fetch(request).first
    }
    
    static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
        let oldInstance = try ManagedCache.find(in: context)
        oldInstance.map(context.delete)
        
        return ManagedCache(context: context)
    }
}
