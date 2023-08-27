

import Foundation

public struct Movie {
    public let id: Int
    public let title: String
    public let overview: String
    public let releaseDate: Date?
    public let posterImageURL: URL
    
    public init(id: Int, title: String, overview: String, releaseDate: Date?, posterImageURL: URL) {
        self.id = id
        self.title = title
        self.overview = overview
        self.releaseDate = releaseDate
        self.posterImageURL = posterImageURL
    }
}
