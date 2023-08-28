

import UIKit

final class WeakReferenceProxy<Object: AnyObject> {
    private weak var object: Object?

    init(_ object: Object) {
        self.object = object
    }
}

extension WeakReferenceProxy: MovieCellPresentable where Object: MovieCellPresentable, Object.Image == UIImage {
    func display(_ viewModel: MovieViewModel<UIImage>) {
        object?.display(viewModel)
    }
}
