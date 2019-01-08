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

    func projects(parentModel: CircleCIModel) -> [ProjectUpdater] {
        let projectNames = projectsString?.components(separatedBy: CharacterSet.whitespaces)
        let client = CircleCIClient.init(apiKey: apiKey!)
        var projects = [ProjectUpdater]()
        if let projectNames = projectNames {
            for projectName in projectNames {
                let filter = Filter.init(userFilter: userFilter, branchFilter: branchFilter)
                // github is hardcoded, as it was assumed
                let project = Project.init(vcsProvider: "github",
                                           organisation: self.organization!,
                                           name: projectName,
                                           filter: filter,
                                           notify: self.notify)

                let projectUpdater = ProjectUpdater(project: project, client: client, buildUpdateListener: parentModel)
                projects.append(projectUpdater)
            }
        }
        return projects
    }

    func valid() -> Bool {
        return apiKey != nil && organization != nil && projectsString != nil
    }
}
