import Foundation
import UIKit

class TableViewDataSource<CellType, EntityType>: NSObject, UITableViewDataSource {

    typealias C = CellType

    typealias E = EntityType

    private let cellReuseIdentifier: String

    private let cellConfigurationHandler: (C, E) -> Void

    private var listItems: [[E]]

    init(cellReuseIdentifier: String, listItems: [E],
         cellConfigurationHandler: @escaping (C, E) -> Void) {
        self.cellReuseIdentifier = cellReuseIdentifier
        self.cellConfigurationHandler = cellConfigurationHandler
        self.listItems = listItems
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)

        cell.selectionStyle = .none

        let listItem = listItems[indexPath.row]

        cellConfigurationHandler(cell as! C, listItem)

        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listItems.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.listItems
    }

    func getListItems() -> [E] {
        return self.listItems
    }

    func setListItems(_ listItems: [E]) {
        self.listItems = listItems
    }

    func clearListItem() {
        self.listItems = []
    }
}

