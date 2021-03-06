import UIKit

public protocol Configurable: AnyObject {
    associatedtype Displayable
    func configure(with displayable: Displayable)
}

public extension UIView {
    static func fromNib(_ nibName: String? = nil, positionInNib position: Int = 0, bundle: Bundle? = nil) -> Self {
        guard let view = UINib(nibName: nibName ?? String(describing: Self.self), bundle: bundle ?? Bundle(for: Self.self))
                .instantiate(withOwner: nil, options: nil)[position] as? Self else {
            preconditionFailure("Nib object instantiaton or cast failed, check the '.xib' file")
        }
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    func addSubviewWithConstraints(_ view: UIView) {
        let constraints = [
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ]
        
        self.addSubview(view)
        
        constraints
            .forEach({
                $0.isActive = true
            })
    }
}

public extension UITableView {
    func register(type: UIView.Type) {
        self.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: type))
    }
    
    func dequeuReusableCell(forType type: UIView.Type, for indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: String(describing: type), for: indexPath)
        
        return cell
    }
}

public extension UIView {
    func contentView<T>(_ type: T.Type) -> T where T: UIView {
        if let view = subviews.first as? T {
            return view
        } else {
            subviews
                .forEach({ $0.removeFromSuperview() })
            let view = T.fromNib()
            addSubviewWithConstraints(view)
            setNeedsLayout()
            layoutIfNeeded()
            return view
        }
    }
    
    func contentView<T>() -> T where T: UIView {
        contentView(T.self)
    }
    
    func configureContentView<T>(_ type: T.Type, with displayable: T.Displayable) where T: UIView & Configurable {
        self.backgroundColor = .clear
        let contentView = self.contentView(T.self)
        contentView.configure(with: displayable)
    }
}
