//
//  AppDelegate.swift
//  SeaEye
//
//  Created by Eoin Nolan on 25/10/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

import Cocoa
import Foundation

import SwiftUI

class AppState: ObservableObject {
    @Published var showPrefrencesWindow: Bool = false
}

//struct MultipleWindowsApp: App {
//    @StateObject var appState = AppState()
//    var body: some Scene {
//        WindowGroup {
//            EmptyView()
//        }
//        WindowGroup {
//            if appState.showPrefrencesWindow {
//                PrefrencesPane()
//                    .environmentObject(appState)
//            }
//        }
//    }
//}


@main
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {

    var statusBarIconViewController: NSController!
    var statusBarItem: NSStatusItem?
    var appState = AppState()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSUserNotificationCenter.default.delegate = self
        self.initialSetup()
        self.setupApplicationMenuViewController()
        let menu = NSMenu()
        let menuItem = NSMenuItem()
          // SwiftUI View
        let view = NSHostingView(rootView: SeaEyePopover()
                                    .environmentObject(appState))

          // Very important! If you don't set the frame the menu won't appear to open.
          view.frame = NSRect(x: 0, y: 0, width: 320, height: 450)
          menuItem.view = view

          menu.addItem(menuItem)

          statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
          statusBarItem?.button?.title = "SeaEye"
          statusBarItem?.menu = menu
    }

    func setupApplicationMenuViewController() {
//        statusBarIconViewController = NSHostingController(rootView: Text("HI"))SeaEyeIconController(nibName: "SeaEyeIconController", bundle: nil)
//        let sui = NSHostingController(rootView: Text("HI"))
        // Very important! If you don't set the frame the menu won't appear to open.
//                view.frame = NSRect(x: 0, y: 0, width: 115, height: 115)
//        statusBarIconViewController.view = view
//        statusBarIcon

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
//            userDefaults.set(true, forKey: SettingsV0.Keys.notify.rawValue)
//            userDefaults.set(true, forKey: "SeaEyePerformedFirstSetup")
            ApplicationStartupManager.toggleLaunchAtStartup()
        }
    }
    
    var preferencesWindow: NSWindow!    // << here

    @objc func openPreferencesWindow() {
        if nil == preferencesWindow {      // create once !!
            let preferencesView = PrefrencesPane()
            // Create the preferences window and set content
            preferencesWindow = NSWindow(
                contentRect: NSRect(x: 20, y: 20, width: 480, height: 300),
                styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                backing: .buffered,
                defer: false)
            preferencesWindow.center()
            preferencesWindow.setFrameAutosaveName("Preferences")
            preferencesWindow.isReleasedWhenClosed = false
            preferencesWindow.contentView = NSHostingView(rootView: preferencesView)
        }
        preferencesWindow.makeKeyAndOrderFront(nil)
        preferencesWindow.orderFrontRegardless()
    }
}
