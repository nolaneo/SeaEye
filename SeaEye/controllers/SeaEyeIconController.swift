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

    enum IconStatus : String {
        case idle = "circleci"
        case success = "circleci-success"
        case failure = "circleci-fail"
        case running = "circleci-running"
    }

    var iconButton: NSStatusBarButton!
    var model = CircleCIModel()
    var applicationStatus = SeaEyeStatus()
    var hasViewedBuilds = true
    var popover = NSPopover()
    var popoverController: SeaEyePopoverController
    let settings = Settings.load()

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

    func colorForState(_ imageName: IconStatus) -> NSColor? {
        switch imageName {
        case .failure:
            return NSColor.systemRed
        case .success:
            return NSColor.systemGreen
        case .running:
            return NSColor.systemYellow
        case .idle:
            return nil
        }
    }

    func setIcon(_ state: IconStatus) {
        let statusImage = NSImage.init(named: state.rawValue)
        statusImage?.size = NSSize.init(width: 16, height: 16)
        statusImage?.isTemplate = true

        if let tintColor = colorForState(state) {
            iconButton.image = statusImage?.tinting(with: tintColor)
        } else {
            iconButton.image = statusImage
        }
    }

    func setupIcon() {
        statusBarItem.target = self

        if let button = statusBarItem.button {
            iconButton = button
            setIcon(.idle)
            button.target = self
            button.action = #selector(openPopover)
            button.isEnabled = true
            button.state = .on
        }
        statusBarItem.action = #selector(openPopover)
    }

    func alert(notification: Notification) {
        UpdateAvailableNotification.display(notification: notification)
    }

    func setGreenBuildIcon(notification: Notification) {
        if hasViewedBuilds {
            setIcon(.success)
            displayBuildNotifcation(notification)
        }
    }

    func setRedBuildIcon(notification: Notification) {
        hasViewedBuilds = false
        setIcon(.failure)
        displayBuildNotifcation(notification)
    }
    
    func setYellowBuildIcon(notification: Notification) -> Void {
        if hasViewedBuilds {
            setIcon(.running)
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

    fileprivate func resetIcon() {
        hasViewedBuilds = true
        setIcon(.idle)
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
