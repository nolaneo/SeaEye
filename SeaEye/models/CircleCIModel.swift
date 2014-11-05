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
            selector: Selector("validateUserSettingsAndStartRequests"),
            name: "SeaEyeSettingsChanged",
            object: nil
        )
        self.validateUserSettingsAndStartRequests()
    }
    
    var allProjects: [Project]!
    var allBuilds: [Build]!
    var lastNotificationDate: NSDate!
    
    func updateProjects() {
        println("Doo Stuff")
    }
    
    func updateBuilds() {
        objc_sync_enter(self)
        
        var builds: [Build] = []
        for (project) in (allProjects) {
            if let projectBuilds = project.projectBuilds {
                builds += projectBuilds
            }
        }
        allBuilds = builds
        allBuilds.sort {$0.date.timeIntervalSince1970 > $1.date.timeIntervalSince1970}
        objc_sync_exit(self)
        
//        for(build) in (allBuilds) {
//            println("\(build.subject) \(build.status) at \(build.date)")
//        }
    }
    
    func validateUserSettingsAndStartRequests() {
        let validation = self.validateKey("SeaEyeAPIKey")
        && self.validateKey("SeaEyeOrganization")
        && self.validateKey("SeaEyeProjects")
        && self.validateKey("SeaEyeUsers")
        
        if (validation) {
            resetAPIRequests()
        } else {
            stopAPIRequests()
        }
    }
    
    private func validateKey(key : String) -> Bool {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let x = userDefaults.stringForKey(key) {
            return true;
        } else {
            return false
        }
    }
    
    private func resetAPIRequests() {
        if let allProjects = allProjects {
            self.stopAPIRequests()
        }
        allProjects = []
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let apiKey = userDefaults.stringForKey("SeaEyeAPIKey") as String!
        let organization = userDefaults.stringForKey("SeaEyeOrganization") as String!
        let projectsString = userDefaults.stringForKey("SeaEyeProjects") as String!
        
        let projectsArray = projectsString.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        for (projectName) in (projectsArray) {
            println("Setting up \(projectName)")
            let project = Project(name: projectName, organization: organization, key:apiKey, parentModel: self)
            allProjects.append(project)
        }
        self.startAPIRequests()
    }
    
    private func startAPIRequests() {
        for (project) in (allProjects) {
            project.reset()
        }
    }
    
    private func stopAPIRequests() {
        for(project) in (allProjects) {
            project.stop();
        }
    }
}
