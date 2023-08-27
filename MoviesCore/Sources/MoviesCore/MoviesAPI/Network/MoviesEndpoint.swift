
import Foundation

public struct MoviesEndpoint {
    
    static var path: String {
        return "discover/movie"
    }
    
    public static func url() -> URL? {
        let urlString = NetworkConfig.apiBaseURL.appendingPathComponent(path)
        var urlComponents = URLComponents(string: urlString)
        urlComponents?.queryItems = [
            URLQueryItem(name: "api_key", value: NetworkConfig.apiKey)
        ]
        
        guard let url = urlComponents?.url else {
            assertionFailure("Unable to configure url with path \(path) and baseURL \(NetworkConfig.apiBaseURL)")
            return nil
        }
        
        return url
    }
}
