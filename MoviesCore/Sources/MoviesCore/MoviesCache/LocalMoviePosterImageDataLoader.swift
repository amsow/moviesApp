
import Foundation

public final class LocalMoviePosterImageDataLoader: ImageDataLoader {
    
    private let store: ImageDataStore
    
    public init(store: ImageDataStore) {
        self.store = store
    }
    
    public enum RetrievalError: Error {
        case notFound
        case failed
    }
    
    private class Task: ImageDataLoaderTask {
        private var completion: ((Result<Data, Error>) -> Void)?
        
        init(_ completion: ((Result<Data, Error>) -> Void)?) {
            self.completion = completion
        }
        
        func cancel() {
            completion = nil
        }
        
        func complete(with result: ImageDataLoader.Result) {
            completion?(result)
        }
    }
    
    public func loadImageData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> ImageDataLoaderTask {
        let task = Task(completion)
        store.retrieveData(for: url) { result in
            task.complete(with:
                            result.mapError { _ in RetrievalError.failed }
                .flatMap { data in
                    data.map { .success($0) } ?? .failure(RetrievalError.notFound)
                }
            )
        }
        
        return task
    }
}

extension LocalMoviePosterImageDataLoader {
    public typealias SaveResult = ImageDataStore.InsertionResult
    
    public enum SaveError: Error {
        case failed
    }
    
    public func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        store.insert(data, for: url) { result in
            switch result {
            case .failure:
                completion(.failure(SaveError.failed))
                
            case .success:
                completion(.success(()))
            }
        }
    }
}

