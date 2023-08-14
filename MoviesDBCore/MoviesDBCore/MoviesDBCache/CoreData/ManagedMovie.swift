

import CoreData

final class ManagedMovie: NSManagedObject {
    @NSManaged var id: Int
    @NSManaged var title: String
    @NSManaged var overview: String
    @NSManaged var releaseData: Date
    @NSManaged var posterImageURL: URL
    @NSManaged var posterImageData: Data?
    @NSManaged var cache: ManagedCache
}
