//
//  SeaEyeBuildsController.swift
//  SeaEye
//
//  Created by Eoin Nolan on 26/10/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

import Cocoa

class SeaEyeBuildsController: NSViewController {

    @IBOutlet weak var fallbackView: NSView!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupFallBackViews()
    }
    
    private func setupFallBackViews() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if  !userDefaults.boolForKey("hasSetupApiKey") {
            println("hasnotsetupapikey")
            return
        }
        if !userDefaults.boolForKey("hasSetupTargetedUsers") {
            println("hasnotsetuptargetedusers")
            return
        }
        fallbackView.hidden = true
    }
    
}
