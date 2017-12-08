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

    var statusBarItem : NSStatusItem = NSStatusItem()
    var statusBarIconViewController : SeaEyeIconController!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSUserNotificationCenter.default.delegate = self
        self.initialSetup()
        statusBarItem = NSStatusBar.system.statusItem(withLength: -1)
        self.setupApplicationMenuViewController()
    }
    
    func setupApplicationMenuViewController() {
        statusBarIconViewController = SeaEyeIconController(nibName: NSNib.Name(rawValue: "SeaEyeIconController"), bundle: nil)
        statusBarItem.view = statusBarIconViewController?.view
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        let userInfo = notification.userInfo

        center.removeDeliveredNotification(notification)
        if let url = userInfo?["url"] as? String{
            NSWorkspace.shared.open(URL(string: url)!)
        }
    }
    
    fileprivate func initialSetup() {
        let userDefaults = UserDefaults.standard
        if userDefaults.bool(forKey: "SeaEyePerformedFirstSetup") == false {
            userDefaults.set(true, forKey: "SeaEyeNotify")
            userDefaults.set(true, forKey: "SeaEyePerformedFirstSetup")
            toggleLaunchAtStartup()
        }
    }
    
    func applicationIsInStartUpItems() -> Bool {
        return (itemReferencesInLoginItems().existingReference != nil)
    }
    
    func itemReferencesInLoginItems() -> (existingReference: LSSharedFileListItem?, lastReference: LSSharedFileListItem?) {
        let appUrl : URL = URL(fileURLWithPath: Bundle.main.bundlePath)
        let loginItemsRef = LSSharedFileListCreate(
                nil,
                kLSSharedFileListSessionLoginItems.takeRetainedValue(),
                nil
        ).takeRetainedValue() as LSSharedFileList?
            if loginItemsRef == nil {
                return (nil, nil)
        }
        let loginItems: NSArray = LSSharedFileListCopySnapshot(loginItemsRef, nil).takeRetainedValue() as NSArray
        print("There are \(loginItems.count) login items")
        let lastItemRef: LSSharedFileListItem = loginItems.lastObject as! LSSharedFileListItem
        
        for currentItemRef in loginItems as! [LSSharedFileListItem] {
            if let itemUrl = LSSharedFileListItemCopyResolvedURL(currentItemRef, 0, nil) {
                if (itemUrl.takeRetainedValue() as URL) == appUrl {
                    return (currentItemRef, lastItemRef)
                }
            } else {
                print("Unknown login application")
            }
        }
       
        //The application was not found in the startup list
        return (nil, lastItemRef)
    }
    
    func toggleLaunchAtStartup() {
        let itemReferences = itemReferencesInLoginItems()
        let shouldBeToggled = (itemReferences.existingReference == nil)
        let loginItemsRef = LSSharedFileListCreate(
            nil,
            kLSSharedFileListSessionLoginItems.takeRetainedValue(),
            nil
            ).takeRetainedValue() as LSSharedFileList?
        if loginItemsRef != nil {
            if shouldBeToggled {
                let appUrl : CFURL = URL(fileURLWithPath: Bundle.main.bundlePath) as CFURL
                
                LSSharedFileListInsertItemURL(
                    loginItemsRef,
                    itemReferences.lastReference,
                    nil,
                    nil,
                    appUrl,
                    nil,
                    nil
                )
                print("Application was added to login items")
            } else {
                if let itemRef = itemReferences.existingReference {
                    LSSharedFileListItemRemove(loginItemsRef,itemRef);
                    print("Application was removed from login items")
                }
            }
        }
    }
}
