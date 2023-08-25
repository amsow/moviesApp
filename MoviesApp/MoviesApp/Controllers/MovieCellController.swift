
import UIKit

protocol MovieCellControllerDelegate {
    func didRequestImageDataLoading()
    func didCancelImageDataLoadingRequest()
}

final class MovieCellController: NSObject, MovieCellPresentable {
    
    private var cell: MovieCell?
    
    private let delegate: MovieCellControllerDelegate
    
    init(delegate: MovieCellControllerDelegate) {
        self.delegate = delegate
    }
    
    ///  The associated View for the controller
    /// - Returns: UITableViewCell
    func view() -> UITableViewCell? {
        cell = MovieCell()
        loadImageData()
        return cell
    }
    
    func display(_ viewModel: MovieViewModel<UIImage>) {
        cell?.titleLabel.text = viewModel.title
        cell?.overviewLabel.text = viewModel.overview
        cell?.releaseDateLabel.text = viewModel.releaseDate
        onLoadingStateChange(viewModel.isLoading)
        cell?.posterImageView.image = viewModel.posterImage
        cell?.retryButton.isHidden = !viewModel.shouldRetry
        cell?.onRetry = delegate.didRequestImageDataLoading
    }
    
    private func onLoadingStateChange(_ isLoading: Bool) {
        isLoading ? cell?.posterImageContainer.startShimmering() : cell?.posterImageContainer.stopShimmering()
    }
    
    // MARK: - Load image data for each cell
    
    private func loadImageData() {
        delegate.didRequestImageDataLoading()
    }
    
    func preloadImageData() {
        loadImageData()
    }
    
    // MARK: - Cancel load image data for each cell
    
    func cancelImageDataLoadTask() {
        // Release the cell as it's no longer visible
        cell = nil
        delegate.didCancelImageDataLoadingRequest()
    }
}
