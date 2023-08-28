
import UIKit

extension UITableView {
    func dequeueCell<Cell: UITableViewCell>() -> Cell {
        dequeueReusableCell(withIdentifier: String(describing: Cell.self)) as! Cell
    }
}
