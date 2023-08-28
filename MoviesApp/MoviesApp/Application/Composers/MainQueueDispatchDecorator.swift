

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

extension MainQueueDispatchDecorator: ImageDataLoader where Decoratee == ImageDataLoader {
    func loadImageData(from url: URL, completion: @escaping (ImageDataLoader.Result) -> Void) -> ImageDataLoaderTask {
        decoratee.loadImageData(from: url) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

// This sounds like a duplication for `ImageDataLoader`. Need to handle it better way
extension MainQueueDispatchDecorator: MoviePosterImageRepository where Decoratee == MoviePosterImageRepository {
    func getImageData(for url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        decoratee.getImageData(for: url) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
