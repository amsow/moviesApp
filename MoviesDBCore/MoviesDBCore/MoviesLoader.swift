
import Foundation

public protocol MoviesLoader {
    typealias Result = Swift.Result<[Movie], Error>
    
    func load(completion: @escaping (Result) -> Void)
}
