
import Foundation
import MoviesApp

extension MovieCell {
    func isShowingLoadingIndicator() -> Bool {
        return posterImageContainer.isShimmering
    }
    
    func isRetryButtonVisibleOnImageView() -> Bool {
        return retryButton.isHidden == false
    }
    
    func simulateRetryAction() {
        retryButton.simulate(event: .touchUpInside)
    }
    
    var renderedImageData: Data? {
        posterImageView.image?.pngData()
    }
}
