

import XCTest
import MoviesDBCore

final class URLSessionHTTPClient {
    
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    enum Error: Swift.Error {
        case noValues
    }
    
    func request(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error {
                completion(.failure(error))
            } else {
                completion(.failure(Error.noValues))
            }
            
        }.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {
    
    func test_requestFromURL_performsGETRequestWithURL() {
        let url = anyURL()
        
        let exp = expectation(description: "Wait for request")
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            
            exp.fulfill()
        }
        
        makeSUT().request(from: url) { _ in }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_requestFromURL_failsOnRequestError() {
    
        let requestError = NSError(domain: "an error", code: 1)
        
        let receivedError = resultErrorFor(data: nil, response: nil, error: requestError) as? NSError
        

        XCTAssertEqual(requestError.domain, receivedError?.domain)
        XCTAssertEqual(requestError.code, receivedError?.code)
    }
    
    func test_requestFromURL_failsOnAllNilValues() {
        
        let receivedError = resultErrorFor(data: nil, response: nil, error: nil)
        
        XCTAssertNotNil(receivedError)
    }
    
    func test_requestFromURL_failsOnNonHTTPURLResponse() {
        let response = URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
       XCTAssertNotNil(resultErrorFor(data: anyData(), response: response, error: nil))
    }
    
    func test_requestFromURL_failsOnNilURLResponse() {
        
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolStub.self]
    
        let sut = URLSessionHTTPClient(session: URLSession(configuration: config))
        trackMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func anyURL() -> URL {
        URL(string: "http://any-url.com")!
    }
    
    func anyData() -> Data {
        Data("any data".utf8)
    }
    
    func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
    
    private func resultErrorFor(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Error? {
        URLProtocolStub.stub(data: data, response: response, error: error)
        let sut = makeSUT(file: file, line: line)
        
        var receivedError: Error?
        let exp = expectation(description: "Wait for request completion")
        sut.request(from: anyURL()) { result in
            switch result {
            case .failure(let error):
                receivedError = error
                
            default:
                XCTFail("Expected failure, got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        return receivedError
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
    
    static func observeRequests(_ observer: @escaping (URLRequest) -> Void) {
        stub = Stub(data: nil, response: nil, error: nil, requestObserver: observer)
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        stub?.requestObserver?(request)
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
