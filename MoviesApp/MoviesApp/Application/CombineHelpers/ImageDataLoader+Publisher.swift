
import Combine
import Foundation
import MoviesCore


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
