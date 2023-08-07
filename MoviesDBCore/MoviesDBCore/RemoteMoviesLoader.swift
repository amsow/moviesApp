

import Foundation

public final class RemoteMoviesLoader: MoviesLoader {
    
    private let url: URL
    private let client: HTTPClient
    
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
                
            case .success:
                completion(.failure(Error.invalidData))
            }
        }
    }
}
