

import XCTest
import MoviesDBCore

final class URLSessionHTTPClient {
    
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func request(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        session.dataTask(with: url) { _, _, error in
            completion(.failure(error!))
        }.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {
    
    func test_requestFromURL_failsOnRequestError() {
        // Given
        let url = URL(string: "http://any-url.com")!
        let error = NSError(domain: "an error", code: 0)
        URLProtocolStub.stub(data: nil, response: nil, error: error)
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolStub.self]
        
        let sut = URLSessionHTTPClient(session: URLSession(configuration: config))
        
        // When
        let exp = expectation(description: "Wait for request completion")
        sut.request(from: url) { result in
            if case .failure(let receivedError as NSError) = result {
                XCTAssertEqual(receivedError.domain, error.domain)
                XCTAssertEqual(receivedError.code, error.code)
            } else {
                XCTFail("Expected failure with error \(error), got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
    }
}


private final class URLProtocolStub: URLProtocol {
    
    struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
        let requestObserver: ((URLRequest) -> Void)?
    }
    
    private static var stub: Stub?
    
    static func stub(data: Data?, response: URLResponse?, error: Error?) {
        stub = Stub(data: data, response: response, error: error, requestObserver: nil)
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let stub = URLProtocolStub.stub else {
            return
        }
        
        if let data = stub.data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        if let response = stub.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() { }
    
}
