
import CoreData
import MoviesCore


final class AppDIContainer {
    
    private(set) lazy var store: MoviesStore & ImageDataStore = {
        let storeURL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("movies-store.sqlite")
        do {
            return try CoreDataMoviesStore(storeURL: storeURL)
        } catch {
            return NullStore()
        }
    }()
    
    private(set) lazy var httpClient: HTTPClient = {
        let session = URLSession(configuration: .ephemeral)
        let client = URLSessionHTTPClient(session: session)
        
        return client
    }()
    
    lazy var posterImageDataRepository: MoviePosterImageRepository = {
        let loader = RemoteMoviePosterImageDataLoader(client: httpClient)
        let repository = DefaultMoviePosterImageRepository(store: store, loader: MainQueueDispatchDecorator(decoratee: loader))
        
        return repository
    }()
}

extension AppDIContainer: MoviePosterImageRepositoryProvider {}
