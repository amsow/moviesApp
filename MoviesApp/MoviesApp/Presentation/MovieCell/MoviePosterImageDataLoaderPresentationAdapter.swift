
import Foundation
import Combine
import MoviesCore

final class MoviePosterImageDataLoaderPresentationAdapter<View: MovieCellPresentable, Image>: MovieCellControllerDelegate where View.Image == Image {
    
    private let model: Movie
    private let imageDataLoader: (URL) -> ImageDataLoader.Publisher
    
    private var cancellable: Cancellable?
    
    var presenter: MovieCellPresenter<View, Image>?
    
    init(model: Movie, imageDataLoader: @escaping (URL) -> ImageDataLoader.Publisher) {
        self.model = model
        self.imageDataLoader = imageDataLoader
    }
    
    func didRequestImageDataLoading() {
        let model = self.model
        presenter?.didStartLoadingImageData(for: model)
        cancellable = imageDataLoader(model.posterImageURL)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                    
                case .failure(let error):
                    self?.presenter?.didFinishLoadingImageDataWithError(error, for: model)
                }
            } receiveValue: { [weak self] data in
                self?.presenter?.didFinishLoadingImageDataWithData(data, for: model)
            }
    }
    
    func didCancelImageDataLoadingRequest() {
        cancellable?.cancel()
        cancellable = nil
    }
}
