//
//  CircleCIModel.swift
//  SeaEye
//
//  Created by Eoin Nolan on 27/10/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

import Cocoa

class CircleCIModel: NSObject {
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
        if Settings.load().valid() {
            allBuilds = []
            NotificationCenter.default.post(name: Notification.Name(rawValue: "SeaEyeUpdatedBuilds"), object: nil)
            resetAPIRequests()
        } else {
            stopAPIRequests()
        }
    }

    fileprivate func resetAPIRequests() {
        self.stopAPIRequests()

        allProjects = Settings.load().projects(parentModel: self)
        self.startAPIRequests()
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
