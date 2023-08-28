
import Foundation

public protocol MovieDetailsRepository {
    func movie(withId id: Int, completion: Result<Movie, Error>)
}
