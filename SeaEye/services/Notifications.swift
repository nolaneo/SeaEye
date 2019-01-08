import Foundation
import Cocoa

struct BuildsNotification {
    private let title: String
    private let subtitle: String
    private let informativeText: String?
    private let url: String

    private let build: CircleCIBuild

    init(_ build: CircleCIBuild, _ count: Int) {
        let endTitle = build.status == .success ? "Sucess" : "Failed"
        let plural = build.status == .success ? "successful" : "failed"
        self.build = build
        self.title = "SeaEye: Build \(endTitle)"
        self.subtitle = count > 1 ? "You have \(count) \(plural) builds" : (build.subject ?? "")
        self.url = build.buildUrl.absoluteString
        self.informativeText = build.authorName
    }

    func toNotification() -> NSUserNotification {
        let notification = NSUserNotification()

        notification.setValue(false, forKey: "_identityImageHasBorder")
        notification.setValue(nil, forKey: "_imageURL")

        notification.setValue(image(), forKey: "_identityImage")
        notification.userInfo = ["url": self.url]
        notification.informativeText = informativeText
        notification.title = title
        notification.subtitle = subtitle

        return notification
    }

    private func image() -> NSImage? {
        let imageFile = build.status == .success ? "build-passed" : "build-failed"
        return NSImage(named: imageFile)
    }
}

struct UpdateAvailableNotification {
    static let notificationCenter = NSUserNotificationCenter.default

    static func display(version: SeaEyeVersion) {
        let url = version.downloadUrl.absoluteString
        let notification = NSUserNotification()
        notification.title = "SeaEye"
        notification.informativeText = "A new version of SeaEye is available (\(version.latestVersion))"
        notification.setValue(true, forKey: "_showsButtons")
        notification.hasActionButton = true
        notification.actionButtonTitle = "Download"
        notification.userInfo = ["url": url]

        notificationCenter.deliver(notification)
    }
}
