

import Foundation
import MoviesCore

final class ImageDataStoreSpy: ImageDataStore {
    private(set) var messages = [Message]()
    private var retrievalCompletions = [(ImageDataStore.RetrievalResult) -> Void]()
    
    enum Message: Equatable {
        case retrieve(dataForURL: URL)
    }
    
    func retrieveData(for url: URL, completion: @escaping (ImageDataStore.RetrievalResult) -> Void) {
        messages.append(.retrieve(dataForURL: url))
        retrievalCompletions.append(completion)
    }
    
    func completeRetrievalWithError(_ error: Error, at index: Int) {
        retrievalCompletions[index](.failure(error))
    }
    
    func completeRetrievalWithData(_ data: Data?, at index: Int) {
        retrievalCompletions[index](.success(data))
    }
}
