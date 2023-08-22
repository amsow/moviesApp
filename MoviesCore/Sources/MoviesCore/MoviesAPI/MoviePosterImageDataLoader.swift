

import Foundation

public final class MoviePosterImageDataLoader {
    public typealias Result = Swift.Result<Data, Error>
    
    private let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public func loadImageData(from url: URL, completion: @escaping (Result) -> Void) {
        client.request(from: url) { result in
            switch result {
            case .success(let (data, response)):
                if response.statusCode != 200 {
                    completion(.failure(.invalidData))
                } else if data.isEmpty && response.statusCode == 200 {
                    completion(.failure(.invalidData))
                } else {
                    completion(.success(data))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}
