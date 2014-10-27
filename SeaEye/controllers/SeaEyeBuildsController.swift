//
//  SeaEyeBuildsController.swift
//  SeaEye
//
//  Created by Eoin Nolan on 26/10/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

import Cocoa

class SeaEyeBuildsController: NSViewController {

    var model : CircleCIModel!
    
    @IBOutlet weak var fallbackView: NSTextField!;
    
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
        if (userDefaults.stringForKey("SeaEyeUsers") == nil) {
            fallbackView.stringValue = "You have not added users to follow"
            return
        }
        fallbackView.hidden = true
    }
    
}
