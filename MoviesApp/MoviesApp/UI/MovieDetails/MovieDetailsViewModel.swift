
import Foundation
import MoviesCore

final class MovieDetailsViewModel {
    
    private let model: Movie
    private let posterImageRepository: MoviePosterImageRepository
    
    var movieTitle: String? {
        model.title
    }
    
    var movieReleaseDate: String? {
        model.releaseDate?.year()
    }
    
    var movieOverview: String? {
        model.overview
    }
    
    var onPosterImageChange: ((Data) -> Void)?
    
    init(model: Movie, posterImageRepository: MoviePosterImageRepository) {
        self.model = model
        self.posterImageRepository = posterImageRepository
    }
    
    func updatePosterImage() {
        posterImageRepository.getImageData(for: model.posterImageURL) { [weak self] result in
            switch result {
            case .success(let data):
                self?.onPosterImageChange?(data)
                
            case .failure:
                // TODO: To be handled
                break
            }
        }
    }
}
