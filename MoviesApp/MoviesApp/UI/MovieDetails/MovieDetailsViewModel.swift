
import Foundation
import MoviesCore

final class MovieDetailsViewModel {
    
    private let model: Movie
    
    var movieTitle: String? {
        model.title
    }
    
    var movieReleaseDate: String? {
        model.releaseDate?.year()
    }
    
    var movieOverview: String? {
        model.overview
    }
    
    init(model: Movie) {
        self.model = model
    }
}
