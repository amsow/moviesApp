

import Foundation
import MoviesCore

final class MainQueueDispatchDecorator<Decoratee> {
    
    private let decoratee: Decoratee
    
    init(decoratee: Decoratee) {
        self.decoratee = decoratee
    }
}

extension MainQueueDispatchDecorator: MoviesLoader where Decoratee == MoviesLoader {
    func load(completion: @escaping (MoviesLoader.Result) -> Void) {
        decoratee.load { result in
            if Thread.isMainThread {
                completion(result)
            } else {
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }
}
