

import Combine
import CoreData
import MoviesCore
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    private var appCoordinator: AppCoordinator?
    
    private lazy var appDependencyContainer: AppDIContainer = {
        AppDIContainer()
    }()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
         appCoordinator = AppCoordinator(dependencies: appDependencyContainer)
        configureWindow(with: appCoordinator)
    }
    
    // MARK: - Private
    
    private func makeRemoteMoviesLoaderWithLocalFallback() -> AnyPublisher<[Movie], Error> {
        let remoteMoviesLoader = RemoteMoviesLoader(url: MoviesEndpoint.url()!, client: appDependencyContainer.httpClient)
        let localMoviesLoader = LocalMoviesLoader(store: appDependencyContainer.store, date: Date.init)
        
        return remoteMoviesLoader
            .loadPublisher()
            .caching(to: localMoviesLoader)
            .fallback(to: localMoviesLoader.loadPublisher)
    }
    
    private func makeLocalImageDataLoaderWithRemoteFallback(url: URL) -> AnyPublisher<Data, Error> {
        let localImgDataLoader = LocalMoviePosterImageDataLoader(store: appDependencyContainer.store)
        let remoteImgDataLoader = RemoteMoviePosterImageDataLoader(client: appDependencyContainer.httpClient)
        
        return localImgDataLoader
            .loadImageDataPublisher(url: url)
            .fallback(to: {
                remoteImgDataLoader.loadImageDataPublisher(url: url)
                    .caching(to: localImgDataLoader, with: url)
            })
    }
    
    private func configureWindow(with appCoordinator: AppCoordinator?) {
        let moviesList = AppComposer.moviesListViewControllerWith(
            moviesLoader: makeRemoteMoviesLoaderWithLocalFallback,
            imageDataLoader: makeLocalImageDataLoaderWithRemoteFallback,
            delegate: appCoordinator
        )
        
        let navController = UINavigationController(rootViewController: moviesList)
        
        appCoordinator?.navigationController = navController
        
        window?.rootViewController = navController
        
        window?.makeKeyAndVisible()
    }
}
