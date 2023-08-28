
import UIKit

public final class LoadMoviesErrorView: UIView {
    
    public var message: String? {
        get { label.text }
        set { label.text = newValue }
    }
    
    let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        makeConstraints()
    }
    
    
    private func setupView() {
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        backgroundColor = UIColor(red: 255, green: 106, blue: 106, alpha: 1)
    }
    
    private func makeConstraints() {
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: 8)
            ]
        )
    }
}
