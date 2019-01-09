import Foundation
import Cocoa

// Delivers a NSUserNotification for a project
class NotificationListener: BuildUpdateListener {
    var notificationCenter = NSUserNotificationCenter.default
    private let initDate = Date()

    func notify(project: Project, builds: [CircleCIBuild]) {
        let filteredBuilds = builds.filter {$0.lastUpdateTime() > initDate}

        if let summary = BuildSummary.generate(builds: filteredBuilds) {
            switch summary.status {
            case .running:
                print("Running build ... skipping notify")
            case .failed:
                if project.notifyFailure {
                    print("Notify of a failed build")
                    let notification = BuildsNotification(summary.build!, summary.count).toNotification()
                    notificationCenter.deliver(notification)
                } else {
                    print("Failed build, but project has failure notifications off")
                }
            case .success:
                if project.notifySuccess {
                    print("Notifiy of a success build")
                    let notification = BuildsNotification(summary.build!, summary.count).toNotification()
                    notificationCenter.deliver(notification)
                } else {
                    print("Success build, but project has success notifications off")
                }
            }
        }
    }
}
