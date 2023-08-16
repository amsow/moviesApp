

import Foundation

final class URLProtocolStub: URLProtocol {
    
    struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
        let requestObserver: ((URLRequest) -> Void)?
    }
    
    private static let queue = DispatchQueue(label: "URLProtocolStub.queue")
    
    private static var _stub: Stub?
    private static var stub: Stub? {
        get { queue.sync { _stub } }
        set { queue.sync { _stub = newValue } }
    }
    
    static func stub(data: Data?, response: URLResponse?, error: Error?) {
        _stub = Stub(data: data, response: response, error: error, requestObserver: nil)
    }
    
    static func observeRequests(_ observer: @escaping (URLRequest) -> Void) {
        _stub = Stub(data: nil, response: nil, error: nil, requestObserver: observer)
    }
    
    static func removeStub() {
        _stub = nil
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
