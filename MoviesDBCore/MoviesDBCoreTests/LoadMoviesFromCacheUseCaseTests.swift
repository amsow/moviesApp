

import XCTest
import MoviesDBCore

final class LoadMoviesFromCacheUseCaseTests: XCTestCase {

    func test_init_doesNotSendMessage() {
        let store = MoviesStoreSpy()
        
        _ = LocalMoviesLoader(store: store)
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    // MARK: - Helpers
    
    final class MoviesStoreSpy: MoviesStore {
        private(set) var messages = [Message]()
        private var deletionCompletions = [MoviesStore.DeletionCompletion]()
        private var insertionCompletions = [MoviesStore.InsertionCompletion]()
        
        enum Message: Equatable {
            case deleteCachedMovies
            case insert([Movie])
        }
        
        func deleteCachedMovies(completion: @escaping DeletionCompletion) {
            messages.append(.deleteCachedMovies)
            deletionCompletions.append(completion)
        }
        
        func insert(_ movies: [Movie], completion: @escaping InsertionCompletion) {
            messages.append(.insert(movies))
            insertionCompletions.append(completion)
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
    }

}
