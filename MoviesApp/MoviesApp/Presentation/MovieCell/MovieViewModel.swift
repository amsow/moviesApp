
import Foundation

struct MovieViewModel<Image> {
    let title: String
    let overview: String
    let releaseDate: String?
    let posterImage: Image?
    let isLoading: Bool
    let shouldRetry: Bool
}
