
import Foundation

public protocol MoviePosterImageRepository {
    func getImageData(for url: URL, completion: @escaping (Result<Data, Error>) -> Void)
}
