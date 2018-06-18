//
//  SeaEyeIconController.swift
//  SeaEye
//
//  Created by Eoin Nolan on 25/10/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

import Cocoa

class SeaEyeIconController: NSViewController {

    @IBOutlet var iconButton: NSButton!
    var model = CircleCIModel()
    var applicationStatus = SeaEyeStatus()
    var hasViewedBuilds = true
    var popover = NSPopover()
    var popoverController: SeaEyePopoverController?

    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    func setup() {
        self.setupMenuBarIcon()
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
        
        if let popoverController = SeaEyePopoverController(nibName: NSNib.Name(rawValue: "SeaEyePopoverController"), bundle: nil) as SeaEyePopoverController? {
            popoverController.model = self.model
            popoverController.applicationStatus = self.applicationStatus
            self.popoverController = popoverController
        }

        NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseUp, .rightMouseUp],
            handler: closePopover
        )

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
            iconButton.image = NSImage(named: NSImage.Name(rawValue: imageFile))

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
        iconButton.image = NSImage(named: NSImage.Name(rawValue: imageFile))

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
            iconButton.image = NSImage(named: NSImage.Name(rawValue: imageFile))
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
        let endTitle = build.status == "success" ? "Sucess" : "Failed"
        let plural = build.status == "success" ?  "successful" : "failed"
        let imageFile = build.status == "success" ? "build-passed" : "build-failed"

        notification.title = "SeaEye: Build \(endTitle)"
        if count > 1 {
            notification.subtitle = "You have \(count) \(plural) builds"
        } else {
            notification.subtitle = build.subject
            notification.informativeText = build.authorName
        }

        let image = NSImage(named: NSImage.Name(rawValue: imageFile))
        notification.setValue(image, forKey: "_identityImage")
        return notification
    }

    fileprivate func setupMenuBarIcon() {
        hasViewedBuilds = true
        let imageFile = isDarkModeEnabled() ? "circleci-normal-alt" : "circleci-normal"
        iconButton.image = NSImage(named: NSImage.Name(rawValue: imageFile))
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
        if let imageName = currentImage?.name()?.rawValue {
            var alternateImageName: NSString
            if imageName.hasSuffix("-alt") {
                alternateImageName = imageName.replacingOccurrences(of: "alt", with: "") as NSString
            } else {
                alternateImageName = imageName + "-alt" as NSString
            }
            iconButton.image = NSImage(named: NSImage.Name(rawValue: alternateImageName as String as String))
        }
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier!.rawValue == "SeaEyeOpenPopoverSegue" {
            self.setupMenuBarIcon()
            if let popoverController = segue.destinationController as? SeaEyePopoverController {
                popoverController.model = self.model
                popoverController.applicationStatus = self.applicationStatus
            }
        }
    }

    @IBAction func openPopover(_ sender: NSButton) {
        self.setupMenuBarIcon()
        if !popover.isShown {
            popover.contentViewController = popoverController
            popover.show(relativeTo: self.view.frame, of: self.view, preferredEdge: NSRectEdge.minY)
        } else {
            popover.close()
        }
    }

    func closePopover(_ aEvent: NSEvent) {
        if popover.isShown {
            popover.close()
        }
    }
}
