//
//  AppDelegate.swift
//  SeaEye
//
//  Created by Eoin Nolan on 25/10/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var statusBarItem : NSStatusItem = NSStatusItem();
    var statusBarIconViewController : SeaEyeIconController?;
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        statusBarItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1);
        self.setupApplicationMenuViewController();
        //self.setupRunOnLogin();
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    
    func setupApplicationMenuViewController() {
        let storyboard = NSStoryboard(name: "Main", bundle: nil);
        statusBarIconViewController = storyboard?.instantiateControllerWithIdentifier("SeaEyeIconController") as? SeaEyeIconController;
        statusBarItem.view = statusBarIconViewController?.view;
    }
    
//    func setupRunOnLogin() {
//        let bundleURL = NSURL.fileURLWithPath(NSBundle.mainBundle().bundlePath)
//        
//        let loginItemsList = LSSharedFileListCreate(
//            nil,
//            kLSSharedFileListSessionLoginItems.takeRetainedValue(),
//            nil
//        )
//        
//        let properties = ["com.apple.loginitem.hideonlaunch": true] as CFDictionaryRef
//        
//        LSSharedFileListInsertItemURL(
//            loginItemsList.takeRetainedValue(),
//            kLSSharedFileListItemLast.takeRetainedValue(),
//            nil,
//            nil,
//            bundleURL,
//            properties,
//            nil
//        )
//    }
    
}

