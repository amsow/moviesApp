

import Foundation

struct MoviesMapper {
    
    private static var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return decoder
    }()
    
    private struct RemoteMoviesResponseDTO: Decodable {
        let results: [RemoteMovieDTO]
    }

    private struct RemoteMovieDTO: Decodable {
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
    
    static func map(_ data: Data, response: HTTPURLResponse) -> MoviesLoader.Result {
        guard response.isOK else {
            return .failure(RemoteMoviesLoader.Error.invalidData)
        }
        
        do {
            let moviesResponse = try decoder.decode(RemoteMoviesResponseDTO.self, from: data)
            return .success(moviesResponse.results.map(\.model))
            
        } catch {
            return .failure(RemoteMoviesLoader.Error.invalidData)
        }
    }
}

private func dateFormatter(format: String = "yyyy-MM-dd") -> DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    return dateFormatter
}
