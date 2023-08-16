

import Foundation
import MoviesCore

final class MoviesStoreSpy: MoviesStore {
    private(set) var messages = [Message]()
    private var deletionCompletions = [MoviesStore.DeletionCompletion]()
    private var insertionCompletions = [MoviesStore.InsertionCompletion]()
    private var retrievalCompletions = [MoviesStore.RetrievalCompletion]()
    
    enum Message: Equatable {
        case deleteCachedMovies
        case insert([Movie])
        case retrieve
    }
    
    func deleteCachedMovies(completion: @escaping DeletionCompletion) {
        messages.append(.deleteCachedMovies)
        deletionCompletions.append(completion)
    }
    
    func insert(_ movies: [Movie], timestamp: Date, completion: @escaping InsertionCompletion) {
        messages.append(.insert(movies))
        insertionCompletions.append(completion)
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        messages.append(.retrieve)
        retrievalCompletions.append(completion)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](.failure(error))
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](.success(()))
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](.success(()))
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
    
    func completeRetrievalSuccessfully(with movies: [Movie], at index: Int = 0) {
        retrievalCompletions[index](.success((movies, Date())))
    }
}
