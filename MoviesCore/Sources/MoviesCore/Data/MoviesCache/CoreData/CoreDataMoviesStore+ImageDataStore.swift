

import Foundation

extension CoreDataMoviesStore: ImageDataStore {
    
    public func retrieveData(for url: URL, completion: @escaping (ImageDataStore.RetrievalResult) -> Void) {
        perform { context in
            completion(Result {
                if let data = context.userInfo[url] as? Data {
                    return data
                }
                
                return try? ManagedMovie.first(with: url, in: context)?.posterImageData
            })
        }
    }
    
    public func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        perform { context in
            completion(Result {
                try ManagedMovie.first(with: url, in: context)
                    .flatMap { $0.posterImageData = data }
                    .map(context.save)
            })
        }
    }
}
