
import Foundation

final public class URLSessionHTTPClient: HTTPClient {
    
    private let session: URLSession
    
    public init(session: URLSession) {
        self.session = session
    }
    
    enum Error: Swift.Error {
        case noValues
    }
    
    public func request(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        session.dataTask(with: url) { data, response, error in
            completion(Result {
                if let error = error {
                    throw error
                } else if let response = response as? HTTPURLResponse, let data = data {
                    return (data, response)
                } else {
                    throw Error.noValues
                }
            })
        }.resume()
    }
}
