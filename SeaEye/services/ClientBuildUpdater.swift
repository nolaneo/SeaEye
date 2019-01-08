import Foundation

// implment this if you want to respond to new builds from a client
protocol BuildUpdateListener {
    mutating func notify(project: Project, builds: [CircleCIBuild])
}

struct TextPrinter: BuildUpdateListener {
    func notify(project: Project, builds: [CircleCIBuild]) {
        print("\(project) got new \(builds.count) builds")
    }
}

// Notifies the listeners with *new* builds that the user cares about for a project, from a buildClient
// on first run it will return all known builds, subsequent notificates will only show updated builds.
class ClientBuildUpdater {
    var listeners: [BuildUpdateListener]
    let client: BuildClient
    let project: Project
    var buildFilter: NewBuildFilter

    init(listeners: [BuildUpdateListener], client: BuildClient, project: Project) {
        self.listeners = listeners
        self.client = client
        self.project = project
        self.buildFilter = NewBuildFilter()
    }

    @objc func getBuilds() {
        client.getProject(name: project.path(), completion: { (result: Result<[CircleCIBuild]>) -> Void in
            switch result {
            case let .success(builds):
                let filteredBuilds = self.buildFilter.newBuilds(project: self.project,
                                                                builds: builds)

                for var listener in self.listeners {
                    listener.notify(project: self.project, builds: filteredBuilds)
                }
                break
            case let .failure(error):
                print("error: \(error.localizedDescription) \(String(describing: self.project))")
            }
        })
    }
}
