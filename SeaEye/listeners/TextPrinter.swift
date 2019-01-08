import Foundation

struct TextPrinter: BuildUpdateListener {
    func notify(project: Project, builds: [CircleCIBuild]) {
        print("\(project) got \(builds.count) new builds")
    }
}
