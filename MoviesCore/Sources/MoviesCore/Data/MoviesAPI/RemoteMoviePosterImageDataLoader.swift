

import Foundation

public protocol ImageDataLoaderTask {
    func cancel()
}

public final class RemoteMoviePosterImageDataLoader: ImageDataLoader {
    
    private let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    private class Task: ImageDataLoaderTask {
        private var completion: ((ImageDataLoader.Result) -> Void)?
        var wrapped: HTTPClientTask?
        
        init(completion: @escaping (ImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func cancel() {
            wrapped?.cancel()
            completion = nil
        }
        
        func complete(with result: ImageDataLoader.Result) {
            completion?(result)
        }
    }
    
    public func loadImageData(from url: URL, completion: @escaping (ImageDataLoader.Result) -> Void) -> ImageDataLoaderTask {
        let task = Task(completion: completion)
        task.wrapped = client.request(from: url) { [weak self] result in
            guard self != nil else { return }
            task.complete(with: result
                .mapError { _ in Error.connectivity }
                .flatMap { (data, response) in
                    let isValid = !data.isEmpty && response.isOK
                    return isValid ? .success(data) : .failure(Error.invalidData)
                }
            )
        }
        
        return task
    }
}
