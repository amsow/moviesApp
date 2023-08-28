

import CoreData

@objc(ManagedMovie)
final class ManagedMovie: NSManagedObject {
    @NSManaged var id: Int
    @NSManaged var title: String
    @NSManaged var overview: String
    @NSManaged var releaseDate: Date?
    @NSManaged var posterImageURL: URL
    @NSManaged var posterImageData: Data?
    @NSManaged var cache: ManagedCache
}

extension ManagedMovie {
    
    var movie: Movie {
        Movie(id: id, title: title, overview: overview, releaseDate: releaseDate, posterImageURL: posterImageURL)
    }
    
    static func first(with url: URL, in context: NSManagedObjectContext) throws -> ManagedMovie? {
        let request = NSFetchRequest<ManagedMovie>(entityName: entity().name!)
        request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(ManagedMovie.posterImageURL), url])
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        
        return try context.fetch(request).first
    }
    
    static func managedMovieOrderSet(from movies: [Movie], in context: NSManagedObjectContext) -> NSOrderedSet {
        NSOrderedSet(
            array: movies.map { movie in
                let managedMovie = ManagedMovie(context: context)
                managedMovie.id = movie.id
                managedMovie.title = movie.title
                managedMovie.overview = movie.overview
                managedMovie.releaseDate = movie.releaseDate
                managedMovie.posterImageURL = movie.posterImageURL
                
                return managedMovie
            }
        )
    }
}
