

import Foundation
import MoviesCore

final class ImageDataStoreSpy: ImageDataStore {
    private(set) var messages = [Message]()
    private var retrievalCompletions = [(ImageDataStore.RetrievalResult) -> Void]()
    private var insertionCompletions = [(ImageDataStore.InsertionResult) -> Void]()
    
    enum Message: Equatable {
        case retrieve(dataForURL: URL)
        case insert(data: Data, for: URL)
    }
    
    func retrieveData(for url: URL, completion: @escaping (RetrievalResult) -> Void) {
        messages.append(.retrieve(dataForURL: url))
        retrievalCompletions.append(completion)
    }
    
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        messages.append(.insert(data: data, for: url))
        insertionCompletions.append(completion)
    }
    
    func completeRetrievalWithError(_ error: Error, at index: Int) {
        retrievalCompletions[index](.failure(error))
    }
    
    func completeRetrievalWithData(_ data: Data?, at index: Int) {
        retrievalCompletions[index](.success(data))
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](.success(()))
    }
}
