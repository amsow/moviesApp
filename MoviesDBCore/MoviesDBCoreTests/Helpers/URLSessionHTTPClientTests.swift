

import XCTest

final class URLSessionHTTPClient {
    
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func request(from url: URL) {
        session.dataTask(with: url)
    }
}

final class URLSessionHTTPClientTests: XCTestCase {
    
    func test_init_doesNotCreateDataTaskWithURL() {
        let session = URLSessionSpy()
        
        _ = URLSessionHTTPClient(session: session)
        
        XCTAssertTrue(session.receivedURLs.isEmpty)
    }
    
    func test_requestFromURL_createsDataTaskWithURL() {
        let url = URL(string: "http://any-url.com")!
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        
        sut.request(from: url)
        
        XCTAssertEqual(session.receivedURLs, [url])
    }
    
    private class URLSessionSpy: URLSession {
        var receivedURLs = [URL]()
        
        override func dataTask(with url: URL) -> URLSessionDataTask {
            receivedURLs.append(url)
            
            return FakeURLSessionDataTask()
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {}

}
