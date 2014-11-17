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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changes.stringValue = applicationStatus.changes
        versionLabel.stringValue = "Version \(applicationStatus.latestVersion) Available"
    }
    
    @IBAction func openUpdatesPage(sender : NSButton) {
        NSWorkspace.sharedWorkspace().openURL(applicationStatus.updateURL)
    }
    
}
