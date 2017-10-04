//
//  SeaEyeIconController.swift
//  SeaEye
//
//  Created by Eoin Nolan on 25/10/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

import Cocoa

class SeaEyeIconController: NSViewController {

    @IBOutlet var iconButton : NSButton!
    var model = CircleCIModel()
    var applicationStatus = SeaEyeStatus()
    var hasViewedBuilds = true
    var popover = NSPopover()
    
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
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(SeaEyeIconController.alert(_:)),
            name: NSNotification.Name(rawValue: "SeaEyeAlert"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(SeaEyeIconController.setRedBuildIcon(_:)),
            name: NSNotification.Name(rawValue: "SeaEyeRedBuild"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(SeaEyeIconController.setGreenBuildIcon(_:)),
            name: NSNotification.Name(rawValue: "SeaEyeGreenBuild"),
            object: nil
        )
        // TODO
//        NSEvent.addGlobalMonitorForEventsMatchingMask(
//            NSEventMask.LeftMouseUp|NSEventMask.RightMouseUp,
//            handler: closePopover
//        )

    }
    
    @objc func alert(_ notification: Notification) {
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
    
    @objc func setGreenBuildIcon(_ notification: Notification) {
        if hasViewedBuilds {
            if (self.isDarkModeEnabled()) {
                iconButton.image = NSImage(named: NSImage.Name(rawValue: "circleci-success-alt"))
            } else {
                iconButton.image = NSImage(named: NSImage.Name(rawValue: "circleci-success"))
            }
            if UserDefaults.standard.bool(forKey: "SeaEyeNotify") {
                let build = notification.userInfo!["build"] as! Build
                let count = notification.userInfo!["count"] as! Int
                showSuccessfulBuildNotification(build, count: count)
            }
        }
    }
    
    @objc func setRedBuildIcon(_ notification: Notification) {
        hasViewedBuilds = false
        if (self.isDarkModeEnabled()) {
            iconButton.image = NSImage(named: NSImage.Name(rawValue: "circleci-failed-alt"))
        } else {
            iconButton.image = NSImage(named: NSImage.Name(rawValue: "circleci-failed"))
        }
        
        if UserDefaults.standard.bool(forKey: "SeaEyeNotify") {
            let build = notification.userInfo!["build"] as! Build
            let count = notification.userInfo!["count"] as! Int
            showFailedBuildNotification(build, count: count)
        }
    }
    
    fileprivate func showFailedBuildNotification(_ build: Build, count: Int) {
        let notification = NSUserNotification()
        notification.title = "SeaEye: Build Failed"
        if count > 1 {
            notification.subtitle = "You have \(count) failed builds"
        } else {
            notification.subtitle = build.subject
            notification.informativeText = build.user
        }
        let image = NSImage(named: NSImage.Name(rawValue: "build-failed"))
        notification.setValue(image, forKey: "_identityImage")
        notification.setValue(false, forKey: "_identityImageHasBorder")
        notification.setValue(nil, forKey:"_imageURL")
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    fileprivate func showSuccessfulBuildNotification(_ build: Build, count: Int) {
        let notification = NSUserNotification()
        notification.title = "SeaEye: Build Passed"
        if count > 1 {
            notification.subtitle = "You have \(count) successful builds"
        } else {
            notification.subtitle = build.subject
            notification.informativeText = build.user
        }
        let image = NSImage(named: NSImage.Name(rawValue: "build-passed"))
        notification.setValue(image, forKey: "_identityImage")
        notification.setValue(false, forKey: "_identityImageHasBorder")
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    fileprivate func setupMenuBarIcon() {
        hasViewedBuilds = true
        if (self.isDarkModeEnabled()) {
            iconButton.image = NSImage(named: NSImage.Name(rawValue: "circleci-normal-alt"))
        } else {
            iconButton.image = NSImage(named: NSImage.Name(rawValue: "circleci-normal"))
        }
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
        let dictionary  = UserDefaults.standard.persistentDomain(forName: UserDefaults.globalDomain);
        if let interfaceStyle = dictionary?["AppleInterfaceStyle"] as? NSString {
            return interfaceStyle.localizedCaseInsensitiveContains("dark")
        } else {
            return false
        }
    }
    
    @objc func alternateIconStyle() {
        let currentImage = iconButton.image
        if let imageName = currentImage?.name()?.rawValue{
            var alternateImageName : NSString
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
            let popoverController = segue.destinationController as! SeaEyePopoverController
            popoverController.model = self.model
            popoverController.applicationStatus = self.applicationStatus
        }
    }
    
    @IBAction func openPopover(_ sender: NSButton) {
        self.setupMenuBarIcon()
        let popoverController = SeaEyePopoverController(nibName: NSNib.Name(rawValue: "SeaEyePopoverController"), bundle: nil) as SeaEyePopoverController!
        popoverController?.model = self.model
        popoverController?.applicationStatus = self.applicationStatus
        let view = popoverController?.view
        
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        if appDelegate.OS_IS_MAVERICKS_OR_LESS() {
            popoverController?.setup()
        }
        
        if !popover.isShown {
            popover.contentViewController = popoverController
            popover.show(relativeTo: self.view.frame, of: self.view, preferredEdge: NSRectEdge.minY)
        } else {
            popover.close()
        }
    }
    
    func closePopover(_ aEvent: (NSEvent!)) -> Void {
        if popover.isShown {
            popover.close()
        }
    }
}
