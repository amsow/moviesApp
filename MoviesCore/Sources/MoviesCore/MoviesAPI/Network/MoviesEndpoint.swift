
import Foundation

struct NetworkConfig {
    static var apiBaseURL: NSString = "https://api.themoviedb.org/3"
    
    static var apiKey: String = {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "ApiKey") as? String else {
            assertionFailure("API_KEY not found")
            return ""
        }
        return apiKey
    }()
}

struct MoviesEndpoint {
    
    static var path: String {
        return "discover/movie"
    }
    
    static func url() -> URL? {
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
