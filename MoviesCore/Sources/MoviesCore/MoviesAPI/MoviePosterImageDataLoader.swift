

import Foundation

public protocol ImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void)
}

public final class MoviePosterImageDataLoader: ImageDataLoader {
    
    private let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public func loadImageData(from url: URL, completion: @escaping (ImageDataLoader.Result) -> Void) {
        client.request(from: url) { result in
            completion(result
                .mapError { _ in Error.connectivity }
                .flatMap { (data, response) in
                    let isValid = !data.isEmpty && response.isOK
                    
                    return isValid ? .success(data) : .failure(Error.invalidData)
                }
            )
        }
    }
}
