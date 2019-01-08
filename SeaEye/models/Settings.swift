import Foundation

struct Settings: Codable {
    enum Keys: String {
        case apiKey = "SeaEyeAPIKey"
        case organisation = "SeaEyeOrganization"
        case projects = "SeaEyeProjects"
        case branchFilter = "SeaEyeBranches"
        case userFilter = "SeaEyeUsers"
        case notify = "SeaEyeNotify"
    }

    var apiKey: String?
    var organization: String?
    var projectsString: String?
    var branchFilter: String?
    var userFilter: String?
    var notify: Bool = true

    static func load(userDefaults: UserDefaults = UserDefaults.standard) -> Settings {
        var settings = self.init()
        settings.apiKey = userDefaults.string(forKey: Keys.apiKey.rawValue)
        settings.organization = userDefaults.string(forKey: Keys.organisation.rawValue)
        settings.projectsString = userDefaults.string(forKey: Keys.projects.rawValue)
        settings.branchFilter = userDefaults.string(forKey: Keys.branchFilter.rawValue)
        settings.userFilter = userDefaults.string(forKey: Keys.userFilter.rawValue)
        settings.notify = userDefaults.bool(forKey: Keys.notify.rawValue)

        return settings
    }

    func projects() -> [ClientProject] {
        let projectNames = projectsString?.components(separatedBy: CharacterSet.whitespaces)
        let client = CircleCIClient.init(apiKey: apiKey!)
        if !valid(){
            return []
        }
        var projects = [Project]()

        if let projectNames = projectNames {
            projects = projectNames.map {
                let filter = Filter.init(userFilter: userFilter, branchFilter: branchFilter)
                // github is hardcoded, as it was assumed
                return Project.init(vcsProvider: "github",
                                   organisation: self.organization!,
                                   name: $0,
                                   filter: filter,
                                   notify: self.notify)
            }
        }
        return [ClientProject.init(client: client, projects: projects)]
    }

    func clientBuildUpdateListeners(listeners: [BuildUpdateListener]) -> [ClientBuildUpdater] {
        let clientProjects = projects()
        return clientProjects.flatMap { (cp) -> [ClientBuildUpdater] in
            cp.projects.map{
                return ClientBuildUpdater(listeners: listeners,
                                          client: cp.client,
                                          project: $0)
            }
        }
    }

    func valid() -> Bool {
        return apiKey != nil && organization != nil && projectsString != nil
    }
}

struct ClientProject: Codable {
    let client: CircleCIClient
    let projects: [Project]
}
