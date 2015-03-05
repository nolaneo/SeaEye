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
    var updatesTimer: NSTimer!
    
    func runModelUpdates() {
        objc_sync_enter(self)
        //Debounce the calls to this function
        if updatesTimer != nil {
            updatesTimer.invalidate()
            updatesTimer = nil
        }
        updatesTimer = NSTimer.scheduledTimerWithTimeInterval(
            NSTimeInterval(3),
            target: self,
            selector: Selector("updateBuilds"),
            userInfo: nil,
            repeats: false
        )
        objc_sync_exit(self)
    }
    
    func updateBuilds() {
        autoreleasepool {
            println("Update builds!")
            var builds: [Build] = []
            for (project) in (self.allProjects) {
                if let projectBuilds = project.projectBuilds {
                    builds += projectBuilds
                }
            }
            self.allBuilds = builds
            self.allBuilds.sort {$0.date.timeIntervalSince1970 > $1.date.timeIntervalSince1970}
            
            self.calculateBuildStatus()
        }
    }
    
    func calculateBuildStatus() {
        if lastNotificationDate != nil {
            var hasGreenBuild = false
            var hasRedBuild = false
            var failures = 0
            var successes = 0
            var failedBuild : Build!
            var successfulBuild : Build!
            for(build) in (allBuilds) {
                if build.date.timeIntervalSince1970 > lastNotificationDate.timeIntervalSince1970 {
                    switch build.status {
                        case "failed": hasRedBuild = true; failures++; failedBuild = build; break;
                        case "timedout": hasRedBuild = true; failures++; failedBuild = build; break;
                        case "success": hasGreenBuild = true; successes++; successfulBuild = build; break;
                        case "fixed": hasGreenBuild = true; successes++; successfulBuild = build; break;
                        default: break;
                    }
                }
            }
            
            if failures > 1 {
                println("Has multiple failues")
                let info = ["build": failedBuild, "count": failures]
                NSNotificationCenter.defaultCenter().postNotificationName("SeaEyeRedBuild", object: nil, userInfo:info)
            } else if hasRedBuild {
                println("Has red build \(failedBuild.subject)")
                let info = ["build": failedBuild, "count": failures]
                NSNotificationCenter.defaultCenter().postNotificationName("SeaEyeRedBuild", object: nil, userInfo:info)
            } else if successes > 1 {
                println("Has multiple successes")
                let info = ["build": successfulBuild, "count": successes]
                NSNotificationCenter.defaultCenter().postNotificationName("SeaEyeGreenBuild", object: nil, userInfo:info)
            } else if hasGreenBuild {
                println("Has green build \(successfulBuild.subject)")
                let info = ["build": successfulBuild, "count": successes]
                NSNotificationCenter.defaultCenter().postNotificationName("SeaEyeGreenBuild", object: nil, userInfo:info)
            }
        }
        NSNotificationCenter.defaultCenter().postNotificationName("SeaEyeUpdatedBuilds", object: nil)
        lastNotificationDate = NSDate()
    }
    
    func validateUserSettingsAndStartRequests() {
        let validation = self.validateKey("SeaEyeCircleCIAPIKey")
        && self.validateKey("SeaEyeCircleCIOrganization")
        && self.validateKey("SeaEyeCircleCIProjects")
        
        if (validation) {
            allBuilds = nil
            NSNotificationCenter.defaultCenter().postNotificationName("SeaEyeUpdatedBuilds", object: nil)
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

        self.stopAPIRequests()
        
        allProjects = []
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let apiKey = userDefaults.stringForKey("SeaEyeCircleCIAPIKey") as String!
        let organization = userDefaults.stringForKey("SeaEyeCircleCIOrganization") as String!
        let projectsString = userDefaults.stringForKey("SeaEyeCircleCIProjects") as String!
        
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
        if updatesTimer != nil {
            updatesTimer.invalidate()
            updatesTimer = nil
        }
        if allProjects == nil {
            return
        }
        for(project) in (allProjects) {
            project.stop();
        }
    }
}
