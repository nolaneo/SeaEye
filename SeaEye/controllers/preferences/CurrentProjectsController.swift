import Cocoa
import Foundation

class CurrentProjectsController: NSObject, NSTextFieldDelegate {
    fileprivate enum CellIdentifiers {
        static let ProjectNameCell = "projectCell"
    }

    private var projects: [Project]
    private var selectedProjectIndex: Int?

    let cellIdentifer = NSUserInterfaceItemIdentifier(rawValue: CellIdentifiers.ProjectNameCell)
    let tableView: NSTableView
    let delegate: ProjectUnfollowedDelegate
    let pUdelegate: ProjectUpdatedDelegate

    init(tableView: NSTableView, projects: [Project], delegate: ProjectUnfollowedDelegate, pUdelegate: ProjectUpdatedDelegate) {
        self.projects = projects
        self.tableView = tableView
        self.delegate = delegate
        self.pUdelegate = pUdelegate

        super.init()
        tableView.delegate = self
        tableView.dataSource = self
    }

    func set(projects: [Project]) {
        self.projects = projects
        tableView.reloadData()
    }

    func tableViewSelectionDidChange(_: Notification) {
        print("hello")
        updateStatus()
    }

    func updateStatus() {
        let itemsSelected = tableView.selectedRow
        if itemsSelected >= 0 {
            selectedProjectIndex = itemsSelected
            print("Probably editing \(projects[itemsSelected]) \(tableView.selectedColumn)")
        } else {
            print("\(itemsSelected) no row is selected")
        }
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
//        print(obj)
        print("Editing \(tableView.editedRow) - \(tableView.editedColumn)")
        print("Clicked \(tableView.clickedRow) - \(tableView.clickedColumn)")
        print("Selected \(tableView.selectedRow) - \(tableView.selectedColumn)")

        if let textField = obj.object as? NSTextField {
            print("just set some value \(textField.tag) to \(textField.stringValue)")
            let branchFilterTag = 1
            let userFilterTag = 2

            if let index = self.selectedProjectIndex {
                var project = projects[index]
                if project.filter == nil {
                    project.filter = Filter(userFilter: nil, branchFilter: nil)
                }
                if textField.tag == branchFilterTag {
                    project.filter?.branchFilter = textField.stringValue
                }
                if textField.tag == userFilterTag {
                    project.filter?.userFilter = textField.stringValue
                }
                print(project)
                projects[index] = project
                pUdelegate.projectUpdated(projectIndex: index, project: project)
            } else {
                print("[WARN] there is no selectedProjectIndex")
            }
        }
        tableView.reloadData()
    }

    @objc func removeProject(_ sender: NSButton) {
        let projectIndex = sender.tag
        delegate.removeProject(projectIndex: projectIndex)
    }

    @objc func notifyToggledSuccess(_ sender: NSButton) {
        var project = projects[sender.tag]
        project.notifySuccess = (sender.state == .on)
        pUdelegate.projectUpdated(projectIndex: sender.tag, project: project)

        print("Success Notifications \(sender.tag) -> \(sender.state) \(project.notifySuccess)")
    }

    @objc func notifyToggledFailure(_ sender: NSButton) {
        var project = projects[sender.tag]
        project.notifyFailure = (sender.state == .on)
        pUdelegate.projectUpdated(projectIndex: sender.tag, project: project)

        print("Failure Notifications \(sender.tag) -> \(sender.state) \(project.notifyFailure)")
    }
}

extension CurrentProjectsController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: cellIdentifer, owner: nil) as? NSTableCellView {
            return tableViewForProjectCell(tableView, viewFor: tableColumn, row: row, cell: cell)
        }

        return nil
    }

    private func tableViewForProjectCell(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int, cell: NSTableCellView) -> NSView? {
        var text: String = "unknown"

        let project = projects[row]

        if tableColumn == tableView.tableColumns[0] {
            text = project.description
        }

        if tableColumn == tableView.tableColumns[1] {
            text = project.filter?.branchFilter ?? "*"
            cell.textField?.tag = 1
            cell.textField?.isEditable = true
            cell.textField?.delegate = self
        }
        if tableColumn == tableView.tableColumns[2] {
            text = project.filter?.userFilter ?? "*"
            cell.textField?.tag = 2

            cell.textField?.isEditable = true
            cell.textField?.delegate = self
        }
        if tableColumn == tableView.tableColumns[3] {
            if #available(OSX 10.12, *) {
                let button = NSButton(checkboxWithTitle: "", target: self, action: #selector(notifyToggledSuccess))
                button.tag = row
                button.state = project.notifySuccess ? .on : .off
                return button

            } else {
                // Fallback on earlier versions
            }
        }
        if tableColumn == tableView.tableColumns[4] {
            if #available(OSX 10.12, *) {
                let button = NSButton(checkboxWithTitle: "", target: self, action: #selector(notifyToggledFailure))
                button.tag = row
                button.state = project.notifyFailure ? .on : .off
                return button

            } else {
                // Fallback on earlier versions
            }
        }
        if tableColumn == tableView.tableColumns[5] {
            if #available(OSX 10.12, *) {
            let button = NSButton(title: "Remove", target: self, action: #selector(removeProject))
                button.setButtonType(NSButton.ButtonType.momentaryPushIn)
                button.tag = row
                return button
            }
        }

        cell.textField?.stringValue = text
        return cell
    }
}

extension CurrentProjectsController: NSTableViewDataSource {
    func numberOfRows(in _: NSTableView) -> Int {
        return projects.count
    }

    func tableView(_ view: NSTableView,
                   objectValueFor col: NSTableColumn?,
                   row index: Int) -> Any? {
//        print("\(index) \(col) \(col?.identifier.rawValue)")
        let project = projects[index]
        switch col?.identifier.rawValue {
        case "projectName":
            return project.description
        case "branchFilter":
            return project.filter?.branchFilter
        case "userRegex":
            return project.filter?.userFilter
        case "notifySuccess":
            return project.notifySuccess
        case "notifyFailure":
            return project.notifyFailure
        default:
            return nil
        }
    }
}
