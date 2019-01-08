import Foundation

struct SeaEyeStatusBarListener: BuildUpdateListener {
    var statusBar: SeaEyeStatusBar
    private let initDate = Date()

    mutating func notify(project: Project, builds: [CircleCIBuild]) {
        print("\(project) got \(builds.count) new builds")

        let buildsAfterApplicationStarted = builds.filter {$0.lastUpdateTime() > initDate}

        if let thing = BuildSummary.generate(builds: buildsAfterApplicationStarted) {
            switch thing.status {
            case .running:
                 statusBar.state = .running
            case .failed:
                print("Set the icon to red")
                statusBar.state = .failure
            case .success:
                print("Set the icon to green")
                statusBar.state = .success
            }
        }
    }
}
