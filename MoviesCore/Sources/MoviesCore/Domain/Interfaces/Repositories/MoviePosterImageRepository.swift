
import Foundation

public protocol MoviePosterImageRepositoryProvider {
    var posterImageDataRepository: MoviePosterImageRepository { get }
}

public protocol MoviePosterImageRepository {
    func getImageData(for url: URL, completion: @escaping (Result<Data, Error>) -> Void)
}
