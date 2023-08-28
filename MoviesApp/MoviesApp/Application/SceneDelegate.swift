

import Combine
import CoreData
import MoviesCore
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        
        let session = URLSession(configuration: .ephemeral)
        let client = URLSessionHTTPClient(session: session)
        let imgDataLoader = RemoteMoviePosterImageDataLoader(client: client)
        
        let moviesList = AppComposer.moviesListViewControllerWith(
            moviesLoader: makeRemoteMoviesLoaderWithLocalFallback,
            imageDataLoader: imgDataLoader
        )
        let moviesListNavController = UINavigationController(rootViewController: moviesList)
        
        window?.rootViewController = moviesListNavController
        
        window?.makeKeyAndVisible()
    }
    
    private func makeRemoteMoviesLoaderWithLocalFallback() -> AnyPublisher<[Movie], Error> {
        let session = URLSession(configuration: .ephemeral)
        let client = URLSessionHTTPClient(session: session)
        let remoteMoviesLoader = RemoteMoviesLoader(url: MoviesEndpoint.url()!, client: client)
        
        let storeURL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("movies-store.sqlite")
        let store = try! CoreDataMoviesStore(storeURL: storeURL)
        let localMoviesLoader = LocalMoviesLoader(store: store, date: Date.init)
        
        return remoteMoviesLoader
            .loadPublisher()
            .caching(to: localMoviesLoader)
            .fallback(to: localMoviesLoader.loadPublisher)
    }
}
