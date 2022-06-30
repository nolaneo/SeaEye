import Cocoa
import Foundation

class UnfollowedProjectsController: NSObject, NSTableViewDelegate, NSTableViewDataSource {
    private let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "AddProjectName")

    private var client: CircleCIClient
    private var projects: [Project]
    private let tableView: NSTableView
    private let delegate: ProjectFollowedDelegate
    private var projectsAlreadyFollwed: [Project]

    init(tableView: NSTableView, client: CircleCIClient, knownProjects: [Project], delegate: ProjectFollowedDelegate) {
        self.client = client
        self.projectsAlreadyFollwed = knownProjects
        projects = []
        self.delegate = delegate
        self.tableView = tableView
        super.init()
        tableView.delegate = self
        tableView.dataSource = self
        reload()
    }

    func reload() {
        client.getProjects { response in
            switch response {
            case let .success(cip):
                self.projects = cip.map { return $0.toProject() }.filter({
                    for followedProject in self.projectsAlreadyFollwed {
                        if $0.description == followedProject.description {
                            return false
                        }
                    }

                    return true
                })
                self.tableView.reloadData()
            case let .failure(err):
                print(err.localizedDescription)
            }
        }
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
            if tableColumn == tableView.tableColumns[0] {
                if row < projects.count {
                    cell.textField?.stringValue = projects[row].description
                    cell.textField?.tag = row
                }
            }

            if tableColumn == tableView.tableColumns[1] {
                if #available(OSX 10.12, *) {
                    let button = NSButton(title: "Add project", target: self, action: #selector(addAProject))
                    button.tag = row
                    return button
                } else {
                    // Fallback on earlier versions
                }
            }
            return cell
        }

        return nil
    }

    func numberOfRows(in _: NSTableView) -> Int {
        return projects.count
    }

    @objc func addAProject(_ sender: NSButton) {
        let project = projects[sender.tag]
        delegate.addProject(project: project)
        projects.remove(at: sender.tag)
        self.tableView.reloadData()
    }
}
