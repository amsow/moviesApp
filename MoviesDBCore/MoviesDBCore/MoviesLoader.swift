
import Foundation

protocol MoviesLoader {
    func load(completion: @escaping (Result<[Movie], Error>) -> Void)
}
