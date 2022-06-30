import Foundation

struct Settings: Codable {
    static let defaultsKey: String = "SeaEyeSettings2"

    var clientProjects: [ClientProject]

    static func load(userDefaults: UserDefaults = UserDefaults.standard) -> Settings {
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
        } else {
            let oldSettings = SettingsV0.load(userDefaults: userDefaults)
            print("Migrating old settings to new settings format")
            settings = oldSettings.toSettings()
            settings.save(userDefaults: userDefaults)
        }

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
