import Cocoa
import Foundation

struct SelectedServerView {
    var apiServerApiPath: NSTextField!
    var apiServerAuthToken: NSTextField!
    var apiServerTestButton: NSButton!

    func fill(client: CircleCIClient) {
        apiServerApiPath.stringValue = client.baseURL
        apiServerAuthToken.stringValue = client.token
        apiServerTestButton.isEnabled = !client.token.isEmpty
    }
}

protocol ProjectFollowedDelegate {
    func addProject(project: Project)
}

protocol ProjectUnfollowedDelegate {
    func removeProject(projectIndex: Int)
}

protocol ProjectUpdatedDelegate {
    func projectUpdated(projectIndex: Int, project: Project)
}

// This is a kind-of-controller, that is used to
class PreferencesWindow: NSWindow, NSWindowDelegate, NSTabViewDelegate, ProjectFollowedDelegate, ProjectUnfollowedDelegate, ProjectUpdatedDelegate {
    // Preferences window
    @IBOutlet var projectsTable: NSTableView!
    @IBOutlet var versionNumber: NSTextField!
    @IBOutlet var launchAtStartup: NSButton!
    @IBOutlet var knownProjectsTable: NSTableView!

    var serverListView: ServerTable?
    var currentProjectsView: CurrentProjectsController!
    var unfollowedProjectsTableView: UnfollowedProjectsController?

    // Servers
    @IBOutlet var serverList: NSTableView!
    @IBOutlet var apiServerApiPath: NSTextField!
    @IBOutlet var apiServerAuthToken: NSSecureTextField!
    @IBOutlet var apiServerTestButton: NSButton!
    @IBOutlet var apiServerDeleteButton: NSButton!

    var settings = Settings.load()
    var iconController: SeaEyeIconController?

    @IBAction func toggleStartup(_ sender: Any) {
        print("Toggle Startup \(sender)")
        if let button = sender as? NSButton {
            print(button.state)
        }
    }

    func windowWillClose(_ notification: Notification) {
        print("Closing window")
        iconController?.reset()
    }

    override func awakeFromNib() {
        versionNumber.stringValue = VersionNumber.current().description
        let selectedServerView = SelectedServerView(apiServerApiPath: apiServerApiPath,
                                                    apiServerAuthToken: apiServerAuthToken,
                                                    apiServerTestButton: apiServerTestButton)

        serverListView = ServerTable(tableView: serverList!,
                                     clients: settings.clients(),
                                     view: selectedServerView)
        self.delegate = self
        super.awakeFromNib()
    }

    func addProject(project: Project) {
        if let client = self.serverListView?.selectedClient() {
            print("Add \(project) to \(client)")

            if let index = self.serverListView?.selectedIndex {
                print("Add Project \(index)")
                settings.clientProjects[index].projects.append(project)
                settings.save()
                currentProjectsView.set(projects: settings.clientProjects[index].projects)
                serverListView?.reloadFromSettings()
                iconController?.reset()
            }
        }
    }

    func removeProject(projectIndex: Int) {
        if var client = self.serverListView?.selectedClient() {
            print("Remove Project \(projectIndex)")

//            print("Remove \(client.projects[projectIndex]) to \(client)")
//
            if let index = self.serverListView?.selectedIndex {
                settings.clientProjects[index].projects.remove(at: projectIndex)
                settings.save()
                serverListView?.reloadFromSettings()
                currentProjectsView.set(projects: settings.clientProjects[index].projects)
                iconController?.reset()
            }
        }
    }

    func projectUpdated(projectIndex: Int, project: Project) {
        if var client = self.serverListView?.selectedClient() {
            print("Project @ \(projectIndex) updated")

//            print("Update \(client.clientProjects[projectIndex]) to \n \(project)")
//
            if let index = self.serverListView?.selectedIndex {
                settings.clientProjects[index].projects[projectIndex] = project
                settings.save()
                currentProjectsView.set(projects: settings.clientProjects[index].projects)
                iconController?.reset()
            }

        } else {}
    }

    func tabView(_: NSTabView, willSelect: NSTabViewItem?) {
        if let item = willSelect {
            if item.label == "Projects" {
                if let client = self.serverListView?.selectedClient() {
                    currentProjectsView = CurrentProjectsController(tableView: projectsTable,
                                                                    projects: settings.projects(),
                                                                    delegate: self,
                                                                    pUdelegate: self)

                    unfollowedProjectsTableView = UnfollowedProjectsController(tableView: knownProjectsTable,
                                                                               client: client,
                                                                               knownProjects: settings.projects(),
                                                                               delegate: self)

                } else {
                    print("There's no clients  .... you can't select projects")
                }
                unfollowedProjectsTableView?.reload()
            }
        }
    }

    @IBAction func testApiServerSelected(_: NSButton) {
        print("test the api server")
        serverListView?.testServer()
    }

    @IBAction func addNewApiServerSelected(_: NSButton) {
        let url = apiServerApiPath.stringValue
        let apiKey = apiServerAuthToken.stringValue
        var client = CircleCIClient.init(apiKey: apiKey)
        client.baseURL = url
        let clientp = ClientProject(client: client, projects: [])

        print("Actually adding now \(client)")
        serverListView?.clients.append(client)
        settings.clientProjects.append(clientp)
        settings.save()
        serverList.reloadData()
    }

    @IBAction func deleteButtonPressed(_: Any) {
        let selected = serverList.selectedRow
        if selected >= 0 {
            settings.clientProjects.remove(at: selected)
            settings.save()
            serverListView?.reloadFromSettings()
        }
    }
}
