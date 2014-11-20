//
//  SeaEyeUpdatesController.swift
//  SeaEye
//
//  Created by Eoin Nolan on 17/11/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

import Cocoa

class SeaEyeUpdatesController: NSViewController {

    var applicationStatus : SeaEyeStatus!
    
    @IBOutlet weak var versionLabel : NSTextField!
    @IBOutlet weak var changes : NSTextField!
    
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        //Mavericks Workaround
        let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
        if appDelegate.OS_IS_MAVERICKS_OR_LESS() {
            for (view) in (self.view.subviews) {
                if let id = view.identifier? {
                    println("Setup: \(id)")
                    switch id {
                    case "VersionLabel": versionLabel = view as NSTextField
                    case "Changes": changes = view as NSTextField
                    default: println("Unknown View \(id)")
                    }
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        changes.stringValue = applicationStatus.changes
        versionLabel.stringValue = "Version \(applicationStatus.latestVersion) Available"
    }
    
    @IBAction func openUpdatesPage(sender : NSButton) {
        NSWorkspace.sharedWorkspace().openURL(applicationStatus.updateURL)
    }
    
}
