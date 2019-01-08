//
//  AppDelegate.swift
//  SeaEye
//
//  Created by Eoin Nolan on 25/10/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

import Cocoa
import Foundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {

    var statusBarIconViewController: SeaEyeIconController!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSUserNotificationCenter.default.delegate = self
        self.initialSetup()
        self.setupApplicationMenuViewController()
    }

    func setupApplicationMenuViewController() {
        statusBarIconViewController = SeaEyeIconController(nibName: "SeaEyeIconController", bundle: nil)
    }

    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }

    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        let userInfo = notification.userInfo

        if let url = userInfo!["url"] as? String {
            NSWorkspace.shared.open(URL(string: url)!)
        }
        center.removeDeliveredNotification(notification)
    }

    fileprivate func initialSetup() {
        let userDefaults = UserDefaults.standard
        if userDefaults.bool(forKey: "SeaEyePerformedFirstSetup") == false {
            userDefaults.set(true, forKey: Settings.Keys.notify.rawValue)
            userDefaults.set(true, forKey: "SeaEyePerformedFirstSetup")
            ApplicationStartupManager.toggleLaunchAtStartup()
        }
    }
}
