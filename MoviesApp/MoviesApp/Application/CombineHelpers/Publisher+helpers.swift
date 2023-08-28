
import Combine
import Foundation
import MoviesCore

extension Publisher where Output == [Movie] {
    func caching(to cache: MoviesCache) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: { movies in
            cache.save(movies) { _ in } // Here we don't really care about the result of that operator, so ignoring the completion
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

extension Publisher {
    func fallback(to fallback: @escaping () -> AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure> {
        self.catch { _ in fallback() }.eraseToAnyPublisher()
    }
}

extension Publisher {
    func dispatchOnMainQueue() -> AnyPublisher<Output, Failure> {
        receive(on: DispatchQueue.immediateWhenOnMainQueueScheduler).eraseToAnyPublisher()
    }
}
