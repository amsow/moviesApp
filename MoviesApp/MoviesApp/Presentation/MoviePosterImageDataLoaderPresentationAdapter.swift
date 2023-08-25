
import MoviesCore

final class MoviePosterImageDataLoaderPresentationAdapter<View: MovieCellPresentable, Image>: MovieCellControllerDelegate where View.Image == Image {
    
    private let model: Movie
    private let imageDataLoader: ImageDataLoader
    private var imageDataLoaderTask: ImageDataLoaderTask?
    
    var presenter: MovieCellPresenter<View, Image>?
    
    init(model: Movie, imageDataLoader: ImageDataLoader) {
        self.model = model
        self.imageDataLoader = imageDataLoader
    }
    
    func didRequestImageDataLoading() {
        let model = self.model
        presenter?.didStartLoadingImageData(for: model)
        imageDataLoaderTask = imageDataLoader.loadImageData(from: model.posterImageURL) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let data):
                presenter?.didFinishLoadingImageDataWithData(data, for: model)
                
            case .failure(let error):
                presenter?.didFinishLoadingImageDataWithError(error, for: model)
            }
        }
    }
    
    func didCancelImageDataLoadingRequest() {
        imageDataLoaderTask?.cancel()
        imageDataLoaderTask = nil
    }
}
