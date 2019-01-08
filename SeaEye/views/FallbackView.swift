import Foundation

struct FallbackView {
    let settings: Settings
    let builds: [CircleCIBuild]

    func description() -> String? {
        if settings.apiKey == nil {
            return "You have not set an API key"
        }
        if settings.organization == nil {
            return "You have not set an organization name"
        }
        if settings.projectsString == nil {
            return "You have not added any projects"
        }
        if builds.count == 0 {
            return "No Recent Builds Found"
        }

        return nil
    }
}
