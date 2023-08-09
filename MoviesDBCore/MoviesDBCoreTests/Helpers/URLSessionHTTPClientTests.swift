

import XCTest
import MoviesDBCore

final class URLSessionHTTPClientTests: XCTestCase {
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.removeStub()
    }
    
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
        
        let requestError = anyNSError()
        
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
    
    func test_requestFromURL_succeedsOnHTTPURLResponseWithData() {
        let url = anyURL()
        let data = anyData()
        let response = anyHTTPURLResponse(for: url)
        
        let receivedValues = resultValuesFor(data: data, response: response, error: nil)
        
        XCTAssertEqual(receivedValues?.data, data)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
    }
    
    func test_requestFromURL_succeedsWithEmptyDataOnHTTPURLResponseWithData() {
        let response = anyHTTPURLResponse()
        let emptyData = Data()
        
        let receivedValues = resultValuesFor(data: nil, response: response, error: nil)
        
        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
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
    
    func anyHTTPURLResponse(for url: URL = URL(string: "http://url.com")!) -> HTTPURLResponse {
        HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func resultErrorFor(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Error? {
        let result = resultFor(data: data, response: response, error: error)
        
        switch result {
        case .failure(let error):
            return error
            
        default:
            XCTFail("Expected failure, got result \(String(describing: result)) instead", file: file, line: line)
            return nil
        }
    }
    
    private func resultValuesFor(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (data: Data, response: HTTPURLResponse)? {
        
        let result = resultFor(data: data, response: response, error: error)
        
        switch result {
        case .success(let (data, response)):
            return (data, response)
            
        default:
            XCTFail("Expected success, got result \(String(describing: result)) instead", file: file, line: line)
            return nil
        }
    }
    
    private func resultFor(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> HTTPClient.Result? {
        
        URLProtocolStub.stub(data: data, response: response, error: error)
        let sut = makeSUT(file: file, line: line)
        
        let exp = expectation(description: "Wait for request completion")
        var receivedResult: HTTPClient.Result?
        sut.request(from: anyURL()) { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        return receivedResult
    }
}
