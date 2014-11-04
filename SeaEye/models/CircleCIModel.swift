//
//  CircleCIModel.swift
//  SeaEye
//
//  Created by Eoin Nolan on 27/10/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

import Cocoa

class CircleCIModel: NSObject {
    
    var hasValidUserSettings = false
    
    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("validateUserSettings"),
            name: "SeaEyeSettingsChanged",
            object: nil
        )
    }
    
    func updateProjects() {
        
    }
    
    private func validateUserSettings() {
        let validation = self.validateKey("SeaEyeAPIKey")
        && self.validateKey("SeaEyeOrganization")
        && self.validateKey("SeaEyeProjects")
        && self.validateKey("SeaEyeUsers")
        hasValidUserSettings = validation
    }
    
    private func validateKey(key : String) -> Bool {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let x = userDefaults.stringForKey(key) {
            return true;
        } else {
            return false
        }
    }
}
