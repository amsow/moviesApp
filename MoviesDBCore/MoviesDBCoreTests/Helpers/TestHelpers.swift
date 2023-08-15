
import Foundation
import MoviesDBCore


func anyNSError() -> NSError {
    NSError(domain: "an error", code: 0)
}

func anyData() -> Data {
    Data("any data".utf8)
}

func anyURL() -> URL {
    URL(string: "http://any-url.com")!
}

func makeMovies() -> [Movie] {
    let movie1 = Movie(
        id: 1,
        title: "title1",
        overview: "overview1",
        releaseDate: Date(timeIntervalSince1970: 1627430400),
        posterImageURL: URL(string: "http://poster-image-base-url.com/w0cn9vwzkheuCT2a2MStdnadOyh.jpg")!
    )
    
    let movie2 = Movie(
        id: 2,
        title: "title2",
        overview: "overview2",
        releaseDate: Date(timeIntervalSince1970: 970617600),
        posterImageURL: URL(string: "http://poster-image-base-url.com/9vwzkheuCT2MStdnadOyh.jpg")!
    )
    
    let movie3 = Movie(
        id: 3,
        title: "title3",
        overview: "overview3",
        releaseDate: Date(timeIntervalSince1970: 1111276800),
        posterImageURL: URL(string: "http://poster-image-base-url.com/9vwzkheuCT2a2MStdnadOyh.jpg")!
    )
    
    return [movie1, movie2, movie3]
}

func makeOtherMovies() -> [Movie] {
    let movie1 = Movie(
        id: 100,
        title: "title100",
        overview: "overview100",
        releaseDate: Date(timeIntervalSince1970: 1627430400),
        posterImageURL: URL(string: "http://poster-image-base-url.com/w0cn9vwzkheuCT2a2MStdnadOyh.jpg")!
    )
    
    let movie2 = Movie(
        id: 2456,
        title: "title2456",
        overview: "overview2456",
        releaseDate: Date(timeIntervalSince1970: 970617600),
        posterImageURL: URL(string: "http://poster-image-base-url.com/9vwzkheuCT2MStdnadOyh.jpg")!
    )
    
    let movie3 = Movie(
        id: 8949234794377539,
        title: "title8949234794377539",
        overview: "overview8949234794377539",
        releaseDate: Date(timeIntervalSince1970: 1111276800),
        posterImageURL: URL(string: "http://poster-image-base-url.com/9vwzkheuCT2a2MStdnadOyh.jpg")!
    )
    
    return [movie1, movie2, movie3]
}
