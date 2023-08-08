
import XCTest
import MoviesDBCore

final class LoadMoviesFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestLoad() {
        // Given & When
        let (client, _) = makeSUT()
        
        // Then
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsFromURL() {
        // Given
        let url = URL(string: "http://an-url.com")!
        let (client, sut) = makeSUT(url: url)
        
        // When
        sut.load { _ in }
        
        // Then
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsTwiceFromURL() {
        // Given
        let url = URL(string: "http://a-given-url.com")!
        let (client, sut) = makeSUT(url: url)
        
        // When
        sut.load { _ in }
        sut.load { _ in }
        
        // Then
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (client, sut) = makeSUT()
        let anyError = NSError(domain: "any error", code: 0)
        
        expect(sut, toCompleteWith: .failure(RemoteMoviesLoader.Error.connectivity), action: {
            client.complete(with: anyError)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (client, sut) = makeSUT()
        let sample = [400, 403, 305, 150, 500, 203]
        
        sample.enumerated().forEach { index, code in
            
            expect(sut, toCompleteWith: .failure(RemoteMoviesLoader.Error.invalidData), action: {
                client.complete(withStatusCode: code, at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (client, sut) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(RemoteMoviesLoader.Error.invalidData), action: {
            
            let invalidData = Data("invalid data".utf8)
            client.complete(withStatusCode: 200, data: invalidData)
        })
    }
    
    func test_load_deliversNoMoviesOn200HTTPResponseWithEmptyJSONData() {
        let (client, sut) = makeSUT()
        
        let emptyJSONData = Data("{\"results\": []}".utf8)
        
        expect(sut, toCompleteWith: .success([]), action: {
            client.complete(withStatusCode: 200, data: emptyJSONData)
        })
    }
    
    func test_load_deliversMoviesItemsOn200HTTPResponseWithValidJSONData() {
        let movie1 = makeMovie(
            id: 1,
            title: "title1",
            overview: "overview1",
            releaseDate: (Date(timeIntervalSince1970: 1627430400), "2021-07-28"),
            posterImageURL: URL(string: "http://poster-image-base-url.com/w0cn9vwzkheuCT2a2MStdnadOyh.jpg")!
        )
        
        let movie2 = makeMovie(
            id: 2,
            title: "title2",
            overview: "overview2",
            releaseDate: (Date(timeIntervalSince1970: 970617600), "2000-10-04"),
            posterImageURL: URL(string: "http://poster-image-base-url.com/9vwzkheuCT2MStdnadOyh.jpg")!
        )
        
        let movie3 = makeMovie(
            id: 3,
            title: "title3",
            overview: "overview3",
            releaseDate: (Date(timeIntervalSince1970: 1111276800), "2005-03-20"),
            posterImageURL: URL(string: "http://poster-image-base-url.com/9vwzkheuCT2a2MStdnadOyh.jpg")!
        )
        
        let remoteMoviesResponseData = makeMovieResponseJSONData([movie1.json, movie2.json, movie3.json])
        
        let (client, sut) = makeSUT()
        
        expect(sut, toCompleteWith: .success([movie1.model, movie2.model, movie3.model]), action: {
            client.complete(withStatusCode: 200, data: remoteMoviesResponseData)
        })
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "http://any-url.com")!) -> (HTTPClientSpy, RemoteMoviesLoader) {
        let client = HTTPClientSpy()
        let sut = RemoteMoviesLoader(url: url, client: client)
        
        return (client, sut)
    }
    
    
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
        
        func complete(withStatusCode code: Int, data: Data = .init(), at index: Int = 0) {
            let url = requestedURLs[index]
            let response = HTTPURLResponse(url: url, statusCode: code, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success((data, response)))
        }
    }
    
    private func expect(_ sut: RemoteMoviesLoader,
                        toCompleteWith expectedResult: MoviesLoader.Result,
                        action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for load")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.failure(let receivedError as RemoteMoviesLoader.Error), .failure(let expectedError as RemoteMoviesLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            case (.success(let receivedMovies), .success(let expectedMovies)):
                XCTAssertEqual(receivedMovies, expectedMovies, file: file, line: line)
                
            default:
                XCTFail("Expected \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeMovie(
        id: Int,
        title: String,
        overview: String,
        releaseDate: (representation: Date, string: String),
        posterImageURL: URL
    ) -> (model: Movie, json: [String: Any]) {
        let model = Movie(id: id, title: title, overview: overview, releaseDate: releaseDate.representation, posterImageURL: posterImageURL)
        let json: [String: Any] = [
            "id": model.id,
            "title": model.title,
            "overview": model.overview,
            "release_date": releaseDate.string,
            "poster_path": model.posterImageURL.lastPathComponent
        ]
        
        return (model, json)
    }
    
    private func makeMovieResponseJSONData(_ json: [[String: Any]]) -> Data {
        let json: [String: Any] = ["results": json]
        
        return try! JSONSerialization.data(withJSONObject: json)
    }
}

extension Movie: Equatable {
    
    public static func ==(lhs: Movie, rhs: Movie) -> Bool {
        return lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.overview == rhs.overview &&
        lhs.releaseDate == rhs.releaseDate &&
        lhs.posterImageURL == rhs.posterImageURL
    }
}
