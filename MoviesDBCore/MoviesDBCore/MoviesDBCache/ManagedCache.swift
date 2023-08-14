

import CoreData

final class ManagedCache: NSManagedObject {
    /// The date when the cache has been made
    @NSManaged var timestamp: Date
    
    /// the set of movies cached
    @NSManaged var movies: NSOrderedSet
}
