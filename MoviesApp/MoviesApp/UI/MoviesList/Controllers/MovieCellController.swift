
import UIKit

protocol MovieCellControllerDelegate {
    func didRequestImageDataLoading()
    func didCancelImageDataLoadingRequest()
}

final class MovieCellController: NSObject, MovieCellPresentable {
    
    private var cell: MovieCell?
    
    private let delegate: MovieCellControllerDelegate
    private let viewModel: MovieViewModel<UIImage>
    
    init(delegate: MovieCellControllerDelegate, viewModel: MovieViewModel<UIImage>) {
        self.delegate = delegate
        self.viewModel = viewModel
    }
    
    ///  The associated View for the controller
    /// - Returns: UITableViewCell
    func view(in tableView: UITableView) -> UITableViewCell? {
        cell = tableView.dequeueCell()
        display(viewModel)
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
        releaseCellForReuse()
        delegate.didCancelImageDataLoadingRequest()
    }
    
    // Release the cell as it's no longer visible and avoid image loaded inconsistency
    private func releaseCellForReuse() {
        cell = nil
    }
}
