//
//  ProjectManager.swift
//  SeaEye
//
//  Created by Eoin Nolan on 28/03/2015.
//  Copyright (c) 2015 Nolaneo. All rights reserved.
//

import Cocoa

class ProjectManager: NSObject {
    
    var allProjects: [Project]!
    var allBuilds: [Build]!
    
    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("validateUserSettingsAndStartRequests"),
            name: "SeaEyeSettingsChanged",
            object: nil
        )
        allProjects = []
        allBuilds = []
        loadProjects()
        runBuildUpdate()
    }
    
    func loadProjects() {
        allProjects.removeAll(keepCapacity: true);
        allBuilds.removeAll(keepCapacity: true);
    }
    
    func runBuildUpdate() {
        
    }
    
}