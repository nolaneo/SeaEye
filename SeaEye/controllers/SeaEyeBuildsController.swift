//
//  SeaEyeBuildsController.swift
//  SeaEye
//
//  Created by Eoin Nolan on 26/10/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

import Cocoa

class SeaEyeBuildsController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    var model : CircleCIModel!
    
    @IBOutlet weak var fallbackView: NSTextField!
    @IBOutlet weak var buildsTable: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
        self.setupFallBackViews()
    }
    
    private func setupFallBackViews() {
        fallbackView.hidden = false
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if  (userDefaults.stringForKey("SeaEyeAPIKey") == nil) {
            fallbackView.stringValue = "You have not set an API key"
            return
        }
        if (userDefaults.stringForKey("SeaEyeOrganization") == nil) {
            fallbackView.stringValue = "You have not set an organization name"
            return
        }
        if (userDefaults.valueForKey("SeaEyeProjects") == nil) {
            fallbackView.stringValue = "You have not added any projects"
            return
        }
        fallbackView.hidden = true
    }
    
    //NSTableViewDataSource
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if model.allBuilds != nil {
            return model.allBuilds.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return model.allBuilds[row]
    }
    
    //NSTableViewDelegate
//    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
//        
//    }

    func selectionShouldChangeInTableView(tableView: NSTableView) -> Bool {
        return false
    }
    
    
}
