

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
            imageDataLoader: makeLocalImageDataLoaderWithRemoteFallback
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
    
    private func makeLocalImageDataLoaderWithRemoteFallback(url: URL) -> AnyPublisher<Data, Error> {
        let storeURL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("movies-store.sqlite")
        let store = try! CoreDataMoviesStore(storeURL: storeURL)
        let localImgDataLoader = LocalMoviePosterImageDataLoader(store: store)
        
        let session = URLSession(configuration: .ephemeral)
        let client = URLSessionHTTPClient(session: session)
        let remoteImgDataLoader = RemoteMoviePosterImageDataLoader(client: client)
        
        return localImgDataLoader
            .loadImageDataPublisher(url: url)
            .fallback(to: {
                remoteImgDataLoader.loadImageDataPublisher(url: url)
                    .caching(to: localImgDataLoader, with: url)
            })
    }
}

extension ImageDataLoader {
    public typealias Publisher = AnyPublisher<Data, Error>
    
    public func loadImageDataPublisher(url: URL) -> Publisher {
        var task: ImageDataLoaderTask?
        return Deferred {
            Future { completion in
                task = loadImageData(from: url, completion: completion)
            }
        }
        .handleEvents(receiveCancel: {
            task?.cancel()
        })
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == Data {
    func caching(to cache: ImageDataCache, with url: URL) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: { data in
            cache.save(data, for: url) { _ in } // Here we don't really care about the result of that operator, so ignoring the completion
        })
        .eraseToAnyPublisher()
    }
}
