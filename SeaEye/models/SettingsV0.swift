import Foundation

struct Settings: Codable {
    private static let defaultsKey: String = "SeaEyeSettings2"

    var clientProjects: [ClientProject]

    static func load(userDefaults: UserDefaults = UserDefaults.standard) -> Settings {
        let oldSettings = SettingsV0.load(userDefaults: userDefaults)

        var settings = Settings(clientProjects: [])
        if let settingsString = userDefaults.string(forKey: self.defaultsKey) {
            let decoder = JSONDecoder()
            if let data = settingsString.data(using: .utf8) {
                do {
                    settings = try decoder.decode(Settings.self, from: data)
                    return settings
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }
        print("Migrating old settings to new settings format")
        settings = oldSettings.toSettings()
        settings.save(userDefaults: userDefaults)
        return settings
    }

    func save(userDefaults: UserDefaults = UserDefaults.standard) {
        for client in clientProjects {
            print("Saving \(client)")
        }

        let jsonEncoder = JSONEncoder()

        do {
            let jsonData = try jsonEncoder.encode(self)
            let json = String(data: jsonData, encoding: String.Encoding.utf8)
            userDefaults.setValue(json, forKey: Settings.defaultsKey)
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func clientBuildUpdateListeners(listeners: [BuildUpdateListener]) -> [ClientBuildUpdater] {
        return clientProjects.flatMap { (cp) -> [ClientBuildUpdater] in
            return cp.projects.map({
                ClientBuildUpdater(listeners: listeners,
                                   client: cp.client,
                                   project: $0)
            })
        }
    }

    func clients() -> [CircleCIClient] {
        return self.clientProjects.map { $0.client}
    }
    func projects() -> [Project] {
        return Array(clientProjects.map {$0.projects}.joined())
    }
    func numberOfProjects() -> Int {
        return clientProjects.compactMap { $0.projects.count }.reduce(0, { $0 + $1 })
    }
}

private struct SettingsV0: Codable {
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

    static func load(userDefaults: UserDefaults = UserDefaults.standard) -> SettingsV0 {
        var settings = self.init()
        settings.apiKey = userDefaults.string(forKey: Keys.apiKey.rawValue)
        settings.organization = userDefaults.string(forKey: Keys.organisation.rawValue)
        settings.projectsString = userDefaults.string(forKey: Keys.projects.rawValue)
        settings.branchFilter = userDefaults.string(forKey: Keys.branchFilter.rawValue)
        settings.userFilter = userDefaults.string(forKey: Keys.userFilter.rawValue)
        settings.notify = userDefaults.bool(forKey: Keys.notify.rawValue)

        return settings
    }

    func toSettings() -> Settings {
        return Settings(clientProjects: self.clientProjects())
    }

    func clientProjects() -> [ClientProject] {
        let projectNames = projectsString?.components(separatedBy: CharacterSet.whitespaces)
        let client = CircleCIClient.init(apiKey: apiKey!)
        if !valid() {
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
                                   notifySuccess: self.notify,
                                   notifyFailure: self.notify
                )
            }
        }
        return [ClientProject.init(client: client, projects: projects)]
    }

    func clients() -> [CircleCIClient] {
        return self.clientProjects().map { $0.client}
    }
    func projects() -> [Project] {
        return Array(clientProjects().map {$0.projects}.joined())
    }

    func clientBuildUpdateListeners(listeners: [BuildUpdateListener]) -> [ClientBuildUpdater] {
        let clientProjects = self.clientProjects()
        return clientProjects.flatMap { (cp) -> [ClientBuildUpdater] in
            cp.projects.map {
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
    var client: CircleCIClient
    var projects: [Project]
}
