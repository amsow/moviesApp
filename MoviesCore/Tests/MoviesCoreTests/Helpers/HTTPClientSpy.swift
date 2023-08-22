
import Foundation
import MoviesCore

final class HTTPClientSpy: HTTPClient {
    
    var requestedURLs: [URL] {
        return messages.map(\.url)
    }
    
    private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
    
    func request(from url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) {
        messages.append((url, completion))
    }
    
    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
        let url = requestedURLs[index]
        let response = HTTPURLResponse(url: url, statusCode: code, httpVersion: nil, headerFields: nil)!
        messages[index].completion(.success((data, response)))
    }
}
