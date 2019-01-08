//
//  SeaEyeIconController.swift
//  SeaEye
//
//  Created by Eoin Nolan on 25/10/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

import Cocoa

class SeaEyeIconController: NSViewController {
    var statusBarItem: SeaEyeStatusBar!
    var model = CircleCIModel()

    var applicationStatus = SeaEyeStatus()

    var hasViewedBuilds = true

    var popover = NSPopover()
    var popoverController: SeaEyePopoverController

    var clientBuildUpdateListeners : [ClientBuildUpdater] = []
    var timers: [Timer] = []

    let settings = Settings.load()

    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        self.popoverController = SeaEyePopoverController(nibName: "SeaEyePopoverController", bundle: nil)
        self.popoverController.model = self.model
        self.popoverController.applicationStatus = self.applicationStatus
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.statusBarItem = SeaEyeStatusBar(controller: self)
        setup()
    }

    required init?(coder: NSCoder) {
        self.popoverController = SeaEyePopoverController(nibName: "SeaEyePopoverController", bundle: nil)
        self.popoverController.model = self.model
        self.popoverController.applicationStatus = self.applicationStatus

        super.init(coder: coder)
        self.statusBarItem = SeaEyeStatusBar(controller: self)
        setup()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    func setup() {
        let secondsToRefreshBuilds = 30
        let listeners : [BuildUpdateListener] = [TextPrinter()]
        clientBuildUpdateListeners = Settings.load().clientBuildUpdateListeners(listeners: listeners)
//        clientBuildUpdateListeners = 
        // keep a timer for each build updater
        self.timers = clientBuildUpdateListeners.map { (cbul) -> Timer in
            return Timer.scheduledTimer(
                timeInterval: TimeInterval(secondsToRefreshBuilds),
                target: cbul,
                selector: #selector(cbul.getBuilds),
                userInfo: nil,
                repeats: true
            )
        }
        for cbul in clientBuildUpdateListeners { cbul.getBuilds() }

        self.resetIcon()
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

    func alert(notification: Notification) {
        UpdateAvailableNotification.display(notification: notification)
    }

    func setGreenBuildIcon(notification: Notification) {
        if hasViewedBuilds {
            statusBarItem.state = .success
            displayBuildNotifcation(notification)
        }
    }

    func setRedBuildIcon(notification: Notification) {
        hasViewedBuilds = false
        statusBarItem.state = .failure
        displayBuildNotifcation(notification)
    }
    
    func setYellowBuildIcon(notification: Notification) -> Void {
        if hasViewedBuilds {
            statusBarItem.state = .running
        }
    }

    func displayBuildNotifcation(_ notification: Notification) {
        if settings.notify {
            if let build = notification.userInfo!["build"] as? CircleCIBuild{
                if let count = notification.userInfo!["count"] as? Int {
                    let bn = BuildsNotification.init(build, count)
                    NSUserNotificationCenter.default.deliver(bn.toNotification())
                }
            }
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

    fileprivate func resetIcon() {
        hasViewedBuilds = true
        statusBarItem.state = .idle
    }

    func closePopover(_ aEvent: Any?) {
        if popover.isShown {
            popover.close()
        }
    }
}
