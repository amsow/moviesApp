
import UIKit


protocol Coordinator {
    func start()
}

final class AppCoordinator: Coordinator {
    
    private let window: UIWindow
    private let viewController: UIViewController
    
    
    init(window: UIWindow, viewController: UIViewController) {
        self.window = window
        self.viewController = viewController
    }
    
    
    func start() {
        window.rootViewController = UINavigationController(rootViewController: viewController)
        window.makeKeyAndVisible()
    }
}
