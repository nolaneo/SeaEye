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
            self.allBuilds = builds.sorted {$0.startTime.timeIntervalSince1970 > $1.startTime.timeIntervalSince1970}
            self.calculateBuildStatus()
        }
    }

    func calculateBuildStatus() {
        if lastNotificationDate != nil {
            var failures = 0
            var successes = 0
            var runningBuilds = 0
            var failedBuild: CircleCIBuild?
            var successfulBuild: CircleCIBuild?
            for build in allBuilds {
                if build.startTime.timeIntervalSince1970 > lastNotificationDate.timeIntervalSince1970 {
                    switch build.status {
                    case .failed: failures += 1; failedBuild = build
                    case .timedout: failures += 1; failedBuild = build
                    case .success: successes += 1; successfulBuild = build
                    case .fixed: successes += 1; successfulBuild = build
                    case .running: runningBuilds += 1
                    default: break
                    }
                }
            }

            if failures > 0 {
                print("Has red build \(String(describing: failedBuild!.subject))")
                let info = ["build": failedBuild!, "count": failures] as [String: Any]
                NotificationCenter.default.post(name: Notification.Name(rawValue: "SeaEyeRedBuild"), object: nil, userInfo: info)
            } else if successes > 0 {
                print("Has multiple successes")
                let info = ["build": successfulBuild!, "count": successes] as [String : Any]
                NotificationCenter.default.post(name: Notification.Name(rawValue: "SeaEyeGreenBuild"), object: nil, userInfo:info)
            } else if runningBuilds > 0 {
                print("Has running builds")
                let info = ["build": nil, "count": runningBuilds] as [String : Any]
                NotificationCenter.default.post(name: Notification.Name(rawValue: "SeaEyeYellowBuild"), object: nil, userInfo:info)
            }
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "SeaEyeUpdatedBuilds"), object: nil)
        lastNotificationDate = Date()
    }

    @objc func validateUserSettingsAndStartRequests() {
        let validation = self.validateKey("SeaEyeAPIKey")
            && self.validateKey("SeaEyeOrganization")
            && self.validateKey("SeaEyeProjects")

        if validation {
            allBuilds = []
            NotificationCenter.default.post(name: Notification.Name(rawValue: "SeaEyeUpdatedBuilds"), object: nil)
            resetAPIRequests()
        } else {
            stopAPIRequests()
        }
    }

    fileprivate func validateKey(_ key: String) -> Bool {
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

        allProjects = projectsFromSettings(apiKey: apiKey!, organisation: organization!, projectNames: projectsArray!)
        self.startAPIRequests()
    }

    func projectsFromSettings(apiKey: String, organisation: String, projectNames: [String]) -> [Project] {
        var projects = [Project]()
        for projectName in projectNames {
            let project = Project(name: projectName, organization: organisation, key: apiKey, parentModel: self)
            projects.append(project)
        }
        return projects
    }

    fileprivate func startAPIRequests() {
        for project in allProjects {
            project.reset()
        }
    }

    fileprivate func stopAPIRequests() {
        if updatesTimer != nil {
            updatesTimer.invalidate()
            updatesTimer = nil
        }
        for project in allProjects {
            project.stop()
        }
    }
}
