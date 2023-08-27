
import Foundation

struct NetworkConfig {
    static var apiBaseURL: NSString = "https://api.themoviedb.org/3"
    static var moviePosterImageApiURL = "https://image.tmdb.org/t/p/w780"
    
    static var apiKey: String = {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "ApiKey") as? String else {
            assertionFailure("API_KEY not found")
            return ""
        }
        return apiKey
    }()
}
