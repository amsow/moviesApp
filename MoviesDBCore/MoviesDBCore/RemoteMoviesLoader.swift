

import Foundation

public final class RemoteMoviesLoader: MoviesLoader {
    
    private let url: URL
    private let client: HTTPClient
    
    private static var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return decoder
    }()
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public func load(completion: @escaping (Result<[Movie], Swift.Error>) -> Void) {
        client.request(from: url) { result in
            switch result {
            case .failure:
                completion(.failure(Error.connectivity))
                
            case .success(let (data, _)):
                if let moviesResponse = try? Self.decoder.decode(RemoteMoviesResponseDTO.self, from: data) {
                    completion(.success(moviesResponse.results.map(\.model)))
                } else {
                    completion(.failure(Error.invalidData))
                }
            }
        }
    }
}

struct RemoteMoviesResponseDTO: Decodable {
    let results: [RemoteMovieDTO]
}

public struct RemoteMovieDTO: Decodable {
    let id: Int
    let title: String
    let overview: String
    let releaseDate: String
    let posterPath: String
    
    var model: Movie {
    let posterImageBaseURL = URL(string: "http://poster-image-base-url.com")!
    let movie = Movie(
            id: id,
            title: title,
            overview: overview,
            releaseDate: dateFormatter().date(from: releaseDate)!,
            posterImageURL: posterImageBaseURL.appending(path: posterPath)
    )
        
        return movie
    }
}

private func dateFormatter(format: String = "yyyy-MM-dd") -> DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    return dateFormatter
}
