

import Foundation

public final class RemoteMoviesLoader {
    
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
    
    public func load(completion: @escaping (Result<[Movie], Error>) -> Void) {
        client.request(from: url) { result in
            switch result {
            case .failure:
                completion(.failure(.connectivity))
                
            case .success:
                completion(.failure(.invalidData))
            }
        }
    }
}
