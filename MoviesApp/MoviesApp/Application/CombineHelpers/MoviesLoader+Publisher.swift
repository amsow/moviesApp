
import Combine
import MoviesCore

extension MoviesLoader {
    public typealias Publisher = AnyPublisher<[Movie], Error>
    
    public func loadPublisher() -> Publisher {
        Deferred { Future(load) }
            .eraseToAnyPublisher()
    }
}
