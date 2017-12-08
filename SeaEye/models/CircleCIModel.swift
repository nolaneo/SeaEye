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
        self.allBuilds = []
        self.allProjects = []

        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(CircleCIModel.validateUserSettingsAndStartRequests),
            name: NSNotification.Name(rawValue: "SeaEyeSettingsChanged"),
            object: nil
        )
        self.validateUserSettingsAndStartRequests()
    }
    
    var allProjects: [Project]
    var allBuilds: [CircleCIBuild]
    var lastNotificationDate: Date!
    var updatesTimer: Timer!
    
    func runModelUpdates() {
        objc_sync_enter(self)
        //Debounce the calls to this function
        if updatesTimer != nil {
            updatesTimer.invalidate()
            updatesTimer = nil
        }
        updatesTimer = Timer.scheduledTimer(
            timeInterval: TimeInterval(3),
            target: self,
            selector: #selector(CircleCIModel.updateBuilds),
            userInfo: nil,
            repeats: false
        )
        objc_sync_exit(self)
    }
    
    @objc func updateBuilds() {
        autoreleasepool {
            print("Update builds!")
            var builds: [CircleCIBuild] = []
            for (project) in (self.allProjects) {
                builds += project.projectBuilds
            }
            self.allBuilds = builds.sorted {$0.start_time.timeIntervalSince1970 > $1.start_time.timeIntervalSince1970}
            self.allBuilds = builds
            self.calculateBuildStatus()
        }
    }
    
    func calculateBuildStatus() {
        if lastNotificationDate != nil {
            var failures = 0
            var successes = 0
            var failedBuild : CircleCIBuild?
            var successfulBuild : CircleCIBuild?
            for(build) in (allBuilds) {
                if build.start_time.timeIntervalSince1970 > lastNotificationDate.timeIntervalSince1970 {
                    switch build.status {
                        case "failed": failures += 1; failedBuild = build; break;
                        case "timedout": failures += 1; failedBuild = build; break;
                        case "success": successes += 1; successfulBuild = build; break;
                        case "fixed": successes += 1; successfulBuild = build; break;
                        default: break;
                    }
                }
            }
            
            if failures > 0 {
//                print("Has red build \(failedBuild!.subject)")
                let info = ["build": failedBuild!, "count": failures] as [String : Any]
                NotificationCenter.default.post(name: Notification.Name(rawValue: "SeaEyeRedBuild"), object: nil, userInfo:info)
            } else if successes > 0 {
                print("Has multiple successes")
                let info = ["build": successfulBuild!, "count": successes] as [String : Any]
                NotificationCenter.default.post(name: Notification.Name(rawValue: "SeaEyeGreenBuild"), object: nil, userInfo:info)
            }
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "SeaEyeUpdatedBuilds"), object: nil)
        lastNotificationDate = Date()
    }
    
    @objc func validateUserSettingsAndStartRequests() {
        let validation = self.validateKey("SeaEyeAPIKey")
            && self.validateKey("SeaEyeOrganization")
            && self.validateKey("SeaEyeProjects")
        
        if (validation) {
            allBuilds = []
            NotificationCenter.default.post(name: Notification.Name(rawValue: "SeaEyeUpdatedBuilds"), object: nil)
            resetAPIRequests()
        } else {
            stopAPIRequests()
        }
    }
    
    fileprivate func validateKey(_ key : String) -> Bool {
        let userDefaults = UserDefaults.standard
        return userDefaults.string(forKey: key) != nil
    }
    
    fileprivate func resetAPIRequests() {

        self.stopAPIRequests()
        
        allProjects = []
        let userDefaults = UserDefaults.standard
        let apiKey = userDefaults.string(forKey: "SeaEyeAPIKey") as String!
        let organization = userDefaults.string(forKey: "SeaEyeOrganization") as String!
        let projectsString = userDefaults.string(forKey: "SeaEyeProjects") as String!
        let projectsArray = projectsString?.components(separatedBy: CharacterSet.whitespaces)
        
 
        allProjects = ProjectsFromSettings(APIKey: apiKey!, Organisation: organization!, ProjectNames: projectsArray!)
        self.startAPIRequests()
    }
    
    func ProjectsFromSettings(APIKey: String, Organisation: String, ProjectNames: [String] ) -> [Project] {
        var projects = [Project]()
        for projectName in ProjectNames {
            let project = Project(name: projectName, organization: Organisation, key:APIKey, parentModel: self)
            projects.append(project)
        }
        return projects
    }
    
    fileprivate func startAPIRequests() {
        for (project) in (allProjects) {
            project.reset()
        }
    }
    
    fileprivate func stopAPIRequests() {
        if updatesTimer != nil {
            updatesTimer.invalidate()
            updatesTimer = nil
        }
        for(project) in (allProjects) {
            project.stop();
        }
    }
}
