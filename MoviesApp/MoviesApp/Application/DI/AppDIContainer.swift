
import CoreData
import MoviesCore


final class AppDIContainer {
    
    private(set) lazy var store: MoviesStore & ImageDataStore = {
        let storeURL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("movies-store.sqlite")
        return try! CoreDataMoviesStore(storeURL: storeURL)
    }()
    
    private(set) lazy var httpClient: HTTPClient = {
        let session = URLSession(configuration: .ephemeral)
        let client = URLSessionHTTPClient(session: session)
        
        return client
    }()
    
    lazy var posterImageDataRepository: MoviePosterImageRepository = {
        DefaultMoviePosterImageRepository(store: store, loader: RemoteMoviePosterImageDataLoader(client: httpClient))
    }()
}

extension AppDIContainer: MoviePosterImageRepositoryProvider {}
