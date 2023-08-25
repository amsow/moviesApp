
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

protocol MovieCellPresentable {
    associatedtype Image
    func display(_ viewModel: MovieViewModel<Image>)
}

final class MovieCellPresenter<View: MovieCellPresentable, Image> where View.Image == Image {
    
    private var view: View
    private let imageTransformer: (Data) -> Image?
    
    init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    func didStartLoadingImageData(for model: Movie) {
        view.display(
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
        view.display(
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
        view.display(
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
final class MovieCellController {
    
    /// Properties to manage the state of the controller
    private let model: Movie
    private let imageDataLoader: ImageDataLoader
    private var imageDataLoaderTask: ImageDataLoaderTask?
    
    init(model: Movie, imageDataLoader: ImageDataLoader) {
        self.model = model
        self.imageDataLoader = imageDataLoader
    }
    
    ///  The associated View for the controller
    /// - Returns: UITableViewCell
    func view() -> UITableViewCell? {
        let cell = MovieCell()
        cell.titleLabel.text = model.title
        cell.overviewLabel.text = model.overview
        cell.releaseDateLabel.text = model.releaseDate.year()
        cell.posterImageContainer.startShimmering()
        cell.retryButton.isHidden = true
        let loadImage = { [ weak self, weak cell] in
            guard let self, let cell else { return }
            loadImageData(forCell: cell)
        }
        cell.onRetry = loadImage
        
        loadImage()
        
        return cell
    }
    
    // MARK: - Load image data for each cell
    
    private func loadImageData(forCell cell: MovieCell) {
        imageDataLoaderTask = imageDataLoader.loadImageData(from: model.posterImageURL) { [weak cell] result in
            switch result {
            case .success(let data):
                let img = UIImage(data: data)
                cell?.posterImageView.image = img
                cell?.retryButton.isHidden = img != nil
            case .failure:
                cell?.retryButton.isHidden = false
            }
            
            cell?.posterImageContainer.stopShimmering()
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
