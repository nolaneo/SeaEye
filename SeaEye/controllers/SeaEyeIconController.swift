//
//  SeaEyeIconController.swift
//  SeaEye
//
//  Created by Eoin Nolan on 25/10/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

import Cocoa

class SeaEyeIconController: NSViewController {
    var statusBarItem: NSStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

    var iconButton: NSStatusBarButton!
    var model = CircleCIModel()
    var applicationStatus = SeaEyeStatus()
    var hasViewedBuilds = true
    var popover = NSPopover()
    var popoverController: SeaEyePopoverController

    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        self.popoverController = SeaEyePopoverController(nibName: "SeaEyePopoverController", bundle: nil)
        self.popoverController.model = self.model
        self.popoverController.applicationStatus = self.applicationStatus

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }

    required init?(coder: NSCoder) {
        self.popoverController = SeaEyePopoverController(nibName: "SeaEyePopoverController", bundle: nil)
        self.popoverController.model = self.model
        self.popoverController.applicationStatus = self.applicationStatus

        super.init(coder: coder)
        setup()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    func setup() {
        self.setupIcon()
        self.resetIcon()
        self.setupStyleNotificationObserver()
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "SeaEyeAlert"),
                                               object: nil,
                                               queue: OperationQueue.main,
                                               using: alert)

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "SeaEyeRedBuild"),
                                               object: nil,
                                               queue: OperationQueue.main,
                                               using: setRedBuildIcon)
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "SeaEyeGreenBuild"),
                                               object: nil,
                                               queue: OperationQueue.main,
                                               using: setGreenBuildIcon)
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "SeaEyeYellowBuild"),
                                               object: nil,
                                               queue: OperationQueue.main,
                                               using: setYellowBuildIcon)
        NotificationCenter.default.addObserver(forName:
                                               NSNotification.Name(rawValue: "SeaEyeClosePopover"),
                                               object: nil,
                                               queue: OperationQueue.main,
                                               using: closePopover)


        NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseUp, .rightMouseUp],
            handler: closePopover
        )

    }

    func setupIcon() {
        statusBarItem.target = self

        if let button = statusBarItem.button {
            let statusImage = NSImage.init(named: "circleci-normal")
            statusImage?.size = NSSize.init(width: 17, height: 17)
            statusImage?.isTemplate = true
            button.image = statusImage
            button.target = self
            button.action = #selector(openPopover)
            button.isEnabled = true
            button.state = .on
            iconButton = button
        }
        statusBarItem.action = #selector(openPopover)
    }

    func alert(notification: Notification) {
        if let userInfo = notification.userInfo {
            if let message = userInfo["message"] as? String {
                let notification = NSUserNotification()
                notification.title = "SeaEye"
                notification.informativeText = message

                if let url = userInfo["url"] as? String {
                    notification.setValue(true, forKey: "_showsButtons")
                    notification.hasActionButton = true
                    notification.actionButtonTitle = "Download"
                    notification.userInfo = ["url": url]
                }

                NSUserNotificationCenter.default.deliver(notification)
            }
        }
    }

    func setGreenBuildIcon(notification: Notification) {
        if hasViewedBuilds {
            let imageFile = self.isDarkModeEnabled() ? "circleci-success-alt" : "circleci-success"
            iconButton.image = NSImage(named: imageFile)

            if UserDefaults.standard.bool(forKey: "SeaEyeNotify") {
                if let build = notification.userInfo!["build"] as? CircleCIBuild{
                    if let count = notification.userInfo!["count"] as? Int {
                        NSUserNotificationCenter.default.deliver(buildNotification(build: build, count: count))
                    }
                }
            }
        }
    }

    func setRedBuildIcon(notification: Notification) {
        hasViewedBuilds = false
        let imageFile = self.isDarkModeEnabled() ? "circleci-failed-alt" : "circleci-failed"
        iconButton.image = NSImage(named: imageFile)

        if UserDefaults.standard.bool(forKey: "SeaEyeNotify") {
            if let build = notification.userInfo!["build"] as? CircleCIBuild{
                if let count = notification.userInfo!["count"] as? Int {
                    NSUserNotificationCenter.default.deliver(buildNotification(build: build, count: count))
                }
            }
        }
    }
    
    func setYellowBuildIcon(notification: Notification) -> Void {
        if hasViewedBuilds {
            let imageFile = self.isDarkModeEnabled() ? "circleci-pending-alt" : "circleci-pending"
            iconButton.image = NSImage(named: imageFile)
        }
    }

    func notifcationForBuild(build: CircleCIBuild) -> NSUserNotification {
        let notification = NSUserNotification()
        notification.setValue(false, forKey: "_identityImageHasBorder")
        notification.setValue(nil, forKey: "_imageURL")
        notification.userInfo = ["url": build.buildUrl.absoluteString]
        return notification
    }

    func buildNotification(build: CircleCIBuild, count: Int) -> NSUserNotification {
        let notification = notifcationForBuild(build: build)
        let endTitle = build.status == .success ? "Sucess" : "Failed"
        let plural = build.status == .success ?  "successful" : "failed"
        let imageFile = build.status == .success ? "build-passed" : "build-failed"

        notification.title = "SeaEye: Build \(endTitle)"
        if count > 1 {
            notification.subtitle = "You have \(count) \(plural) builds"
        } else {
            notification.subtitle = build.subject
            notification.informativeText = build.authorName
        }

        let image = NSImage(named: imageFile)
        notification.setValue(image, forKey: "_identityImage")
        return notification
    }

    fileprivate func resetIcon() {
        hasViewedBuilds = true
        let imageFile = isDarkModeEnabled() ? "circleci-normal-alt" : "circleci-normal"
        iconButton.image = NSImage(named: imageFile)
    }

    fileprivate func setupStyleNotificationObserver() {
        DistributedNotificationCenter.default()
            .addObserver(
                self,
                selector: #selector(SeaEyeIconController.alternateIconStyle),
                name: NSNotification.Name(rawValue: "AppleInterfaceThemeChangedNotification"),
                object: nil
        )
    }

    fileprivate func isDarkModeEnabled() -> Bool {
        let dictionary  = UserDefaults.standard.persistentDomain(forName: UserDefaults.globalDomain)
        if let interfaceStyle = dictionary?["AppleInterfaceStyle"] as? NSString {
            return interfaceStyle.localizedCaseInsensitiveContains("dark")
        } else {
            return false
        }
    }

    @objc func alternateIconStyle() {
        let currentImage = iconButton.image
        if let imageName = currentImage?.name() {
            var alternateImageName: NSString
            if imageName.hasSuffix("-alt") {
                alternateImageName = imageName.replacingOccurrences(of: "alt", with: "") as NSString
            } else {
                alternateImageName = imageName + "-alt" as NSString
            }
            iconButton.image = NSImage(named: alternateImageName as String as String)
        }
    }

    @objc func openPopover(_ sender: NSButton) {
        self.resetIcon()
        if !popover.isShown {
            popoverController.model = self.model
            popoverController.applicationStatus = self.applicationStatus
            popover.contentViewController = popoverController
            popover.show(relativeTo: sender.frame, of: sender, preferredEdge: NSRectEdge.minY)
        } else {
            popover.close()
        }
    }

    func closePopover(_ aEvent: Any?) {
        if popover.isShown {
            popover.close()
        }
    }
}
