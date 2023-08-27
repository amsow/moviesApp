

import UIKit
import MoviesCore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        
        let session = URLSession(configuration: .ephemeral)
        let client = URLSessionHTTPClient(session: session)
        let moviesLoader = RemoteMoviesLoader(url: MoviesEndpoint.url()!, client: client)
        let imgDataLoader = RemoteMoviePosterImageDataLoader(client: client)
        
        let moviesList = AppComposer.moviesListViewController(
            moviesLoader: moviesLoader,
            imageDataLoader: imgDataLoader
        )
        let moviesListNavController = UINavigationController(rootViewController: moviesList)
        
        window?.rootViewController = moviesListNavController
        
        window?.makeKeyAndVisible()
    }
}

