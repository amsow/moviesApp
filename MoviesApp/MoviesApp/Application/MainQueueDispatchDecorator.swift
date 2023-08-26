

import Foundation
import MoviesCore

final class MainQueueDispatchDecorator<Decoratee> {
    
    private let decoratee: Decoratee
    
    init(decoratee: Decoratee) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async(execute: completion)
        }
        completion()
    }
}

extension MainQueueDispatchDecorator: MoviesLoader where Decoratee == MoviesLoader {
    func load(completion: @escaping (MoviesLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
