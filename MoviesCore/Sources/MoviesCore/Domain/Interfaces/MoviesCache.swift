
import Foundation

public protocol MoviesCache {
    typealias SaveResult = Result<Void, Error>
    
    func save(_ movies: [Movie], completion: @escaping (SaveResult) -> Void)
}
