
import Foundation
import MoviesCore

final class HTTPClientSpy: HTTPClient {
    
    var requestedURLs: [URL] {
        return messages.map(\.url)
    }
    
    private(set) var cancelledURLs = [URL]()
    
    private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
    
    private struct Task: HTTPClientTask {
        private let onCancel: () -> Void
        
        init(onCancel: @escaping () -> Void) {
            self.onCancel = onCancel
        }
        
        func cancel() {
            onCancel()
        }
    }
    
    func request(from url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) -> HTTPClientTask {
        messages.append((url, completion))
        return Task(onCancel: { [weak self] in
            self?.cancelledURLs.append(url)
            
        })
        
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
