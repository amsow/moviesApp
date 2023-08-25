
import UIKit
import MoviesCore

struct MovieViewModel<Image> {
    let title: String
    let overview: String
    let releaseDate: String?
    let posterImage: Image?
    let isLoading: Bool
    let shouldRetry: Bool
}

protocol MovieCellPresentable: AnyObject {
    associatedtype Image
    func display(_ viewModel: MovieViewModel<Image>)
}

final class MovieCellPresenter<View: MovieCellPresentable, Image> where View.Image == Image {
    
    private weak var view: View?
    private let imageTransformer: (Data) -> Image?
    
    init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    func didStartLoadingImageData(for model: Movie) {
        view?.display(
            MovieViewModel(
                title: model.title,
                overview: model.overview,
                releaseDate: model.releaseDate.year(),
                posterImage: nil,
                isLoading: true,
                shouldRetry: false)
        )
    }
    
    func didFinishLoadingImageDataWithData(_ data: Data, for model: Movie) {
        let img = imageTransformer(data)
        view?.display(
            MovieViewModel(
                title: model.title,
                overview: model.overview,
                releaseDate: model.releaseDate.year(),
                posterImage: img,
                isLoading: false,
                shouldRetry: img == nil)
        )
    }
    
    func didFinishLoadingImageDataWithError(_ error: Error, for model: Movie) {
        view?.display(
            MovieViewModel(
                title: model.title,
                overview: model.overview,
                releaseDate: model.releaseDate.year(),
                posterImage: nil,
                isLoading: false,
                shouldRetry: true)
        )
    }
}

final class MovieCellController: MovieCellPresentable {
    
    /// Properties to manage the state of the controller
    private let model: Movie
    private let imageDataLoader: ImageDataLoader
    private var imageDataLoaderTask: ImageDataLoaderTask?
    
    private var cell: MovieCell?
    
    var presenter: MovieCellPresenter<MovieCellController, UIImage>?
    
    init(model: Movie, imageDataLoader: ImageDataLoader) {
        self.model = model
        self.imageDataLoader = imageDataLoader
    }
    
    ///  The associated View for the controller
    /// - Returns: UITableViewCell
    func view() -> UITableViewCell? {
        cell = MovieCell()
        let loadImage = { [ weak self] in
            guard let self else { return }
            loadImageData()
        }
        cell?.onRetry = loadImage
        
        loadImage()
        
        return cell
    }
    
    func display(_ viewModel: MovieViewModel<UIImage>) {
        cell?.titleLabel.text = viewModel.title
        cell?.overviewLabel.text = viewModel.overview
        cell?.releaseDateLabel.text = viewModel.releaseDate
        viewModel.isLoading ? cell?.posterImageContainer.startShimmering() : cell?.posterImageContainer.stopShimmering()
        cell?.posterImageView.image = viewModel.posterImage
        cell?.retryButton.isHidden = !viewModel.shouldRetry
    }
    
    // MARK: - Load image data for each cell
    
    private func loadImageData() {
        let movie = self.model
        presenter?.didStartLoadingImageData(for: movie)
        imageDataLoaderTask = imageDataLoader.loadImageData(from: model.posterImageURL) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let data):
                presenter?.didFinishLoadingImageDataWithData(data, for: movie)
                
            case .failure(let error):
                presenter?.didFinishLoadingImageDataWithError(error, for: movie)
            }
        }
    }
    
    func preloadImageData() {
        imageDataLoaderTask = imageDataLoader.loadImageData(from: model.posterImageURL) { _ in }
    }
    
    func cancelImageDataLoadTask() {
        imageDataLoaderTask?.cancel()
        imageDataLoaderTask = nil
    }
}
