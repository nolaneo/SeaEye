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
    var applicationStatus = SeaEyeStatus()

    var hasViewedBuilds = true

    var popover = NSPopover()
    var popoverController: SeaEyePopoverController

    var clientBuildUpdateListeners : [ClientBuildUpdater] = []
    var timers: [Timer] = []

    let settings = Settings.load()

    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        self.popoverController = SeaEyePopoverController(nibName: "SeaEyePopoverController", bundle: nil)
        self.popoverController.applicationStatus = self.applicationStatus
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.statusBarItem = SeaEyeStatusBar(controller: self)
        setup()
    }

    required init?(coder: NSCoder) {
        self.popoverController = SeaEyePopoverController(nibName: "SeaEyePopoverController", bundle: nil)
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
        let popoverControllerBuildListener = PopoverContollerBuildUpdateListener(buildSetter: popoverController)

        let listeners : [BuildUpdateListener] = [TextPrinter(),
                                                 popoverControllerBuildListener,
                                                 SeaEyeStatusBarListener.init(statusBar: self.statusBarItem),
                                                 NotificationListener()]

        clientBuildUpdateListeners = Settings.load().clientBuildUpdateListeners(listeners: listeners)

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

    @objc func openPopover(_ sender: NSButton) {
        self.resetIcon()
        if !popover.isShown {
//            popoverController.model = self.model
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
