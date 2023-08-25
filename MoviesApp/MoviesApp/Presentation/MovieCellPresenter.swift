

import Foundation
import MoviesCore

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

private extension Date {
    func year() -> String {
        let calendar = Calendar(identifier: .gregorian)
        let yearComponent = calendar.component(.year, from: self)
        
        return yearComponent.description
    }
}
