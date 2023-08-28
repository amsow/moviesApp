

import Combine
import CoreData
import MoviesCore
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    private let storeURL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("movies-store.sqlite")
    
    private lazy var store: MoviesStore & ImageDataStore = {
        try! CoreDataMoviesStore(storeURL: storeURL)
    }()
    
    private lazy var httpClient: HTTPClient = {
        let session = URLSession(configuration: .ephemeral)
        let client = URLSessionHTTPClient(session: session)
        
        return client
    }()
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        
        let moviesList = AppComposer.moviesListViewControllerWith(
            moviesLoader: makeRemoteMoviesLoaderWithLocalFallback,
            imageDataLoader: makeLocalImageDataLoaderWithRemoteFallback
        )
        
        let appCoordinator: Coordinator = AppCoordinator(window: window!, viewController: moviesList)
       
        appCoordinator.start()
    }
    
    // MARK: - Private
    
    private func makeRemoteMoviesLoaderWithLocalFallback() -> AnyPublisher<[Movie], Error> {
        let remoteMoviesLoader = RemoteMoviesLoader(url: MoviesEndpoint.url()!, client: httpClient)
        let localMoviesLoader = LocalMoviesLoader(store: store, date: Date.init)
        
        return remoteMoviesLoader
            .loadPublisher()
            .caching(to: localMoviesLoader)
            .fallback(to: localMoviesLoader.loadPublisher)
    }
    
    private func makeLocalImageDataLoaderWithRemoteFallback(url: URL) -> AnyPublisher<Data, Error> {
        let localImgDataLoader = LocalMoviePosterImageDataLoader(store: store)
        let remoteImgDataLoader = RemoteMoviePosterImageDataLoader(client: httpClient)
        
        return localImgDataLoader
            .loadImageDataPublisher(url: url)
            .fallback(to: {
                remoteImgDataLoader.loadImageDataPublisher(url: url)
                    .caching(to: localImgDataLoader, with: url)
            })
    }
}
