import Foundation

protocol IconSetter {
    var state : SeaEyeStatusBar.IconStatus { get set }
}

struct SeaEyeStatusBarListener: BuildUpdateListener {
    var statusBar: IconSetter
    private let initDate = Date()

    mutating func notify(project: Project, builds: [CircleCIBuild]) {
        let buildsAfterApplicationStarted = builds.filter {$0.lastUpdateTime() > initDate}

        if let buildSummary = BuildSummary.generate(builds: buildsAfterApplicationStarted) {
            switch buildSummary.status {
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
