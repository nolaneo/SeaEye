//
//  CircleCIModel.swift
//  SeaEye
//
//  Created by Eoin Nolan on 27/10/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

import Cocoa

class CircleCIModel: NSObject, BuildUpdateListener {
    override init() {
        self.allBuilds = []
        self.projectUpdaters = []

        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(CircleCIModel.validateUserSettingsAndStartRequests),
            name: NSNotification.Name(rawValue: "SeaEyeSettingsChanged"),
            object: nil
        )
        self.validateUserSettingsAndStartRequests()
    }

    var projectUpdaters: [ProjectUpdater]
    var allBuilds: [CircleCIBuild]
    var lastNotificationDate: Date = Date()
    var updatesTimer: Timer!

    // a 3second debounce proxy to updateBuilds
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

    // collects all builds from the projectUpdaters and recalculates the build status
    @objc func updateBuilds() {
        autoreleasepool {
            print("Update builds!")
            let builds: [CircleCIBuild] = self.projectUpdaters.flatMap {$0.projectBuilds}
            self.allBuilds = builds.sorted {$0.lastUpdateTime() > $1.lastUpdateTime()}
            self.calculateBuildStatus()
        }
    }

    private func calculateBuildStatus() {
        let buildsSinceLastNotification = allBuilds.filter {$0.lastUpdateTime() > lastNotificationDate}
        print("\(buildsSinceLastNotification.count) builds to update")
        if let summary = BuildSummary.generate(builds: buildsSinceLastNotification) {
            print(summary.status)
            switch summary.status {
            case .running:
                print("Has running builds")
                let info = ["build": nil, "count": summary.count] as [String : Any]
                NotificationCenter.default.post(name: Notification.Name(rawValue: "SeaEyeYellowBuild"), object: nil, userInfo:info)
            case .failed:
                print("Has red build \(String(describing: summary.build!.subject))")
                let info = ["build": summary.build!, "count": summary.count] as [String: Any]
                NotificationCenter.default.post(name: Notification.Name(rawValue: "SeaEyeRedBuild"), object: nil, userInfo: info)
            case .success:
                print("Notifiy of a success build")
                let info = ["build": summary.build!, "count": summary.count] as [String : Any]
                NotificationCenter.default.post(name: Notification.Name(rawValue: "SeaEyeGreenBuild"), object: nil, userInfo:info)
            }
        }
        if buildsSinceLastNotification.count > 0 {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "SeaEyeUpdatedBuilds"), object: nil)
            lastNotificationDate = Date()
        }
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
        self.projectUpdaters = projectUpdaters(Settings.load())
        self.startAPIRequests()
    }

    private func projectUpdaters(_ settings: Settings) -> [ProjectUpdater] {
        let cp = settings.projects()
        let projectUpdaters = cp.compactMap { (cps) -> [ProjectUpdater] in
            return cps.projects.compactMap {
                return ProjectUpdater.init(project: $0, client: cps.client, buildUpdateListener: self)
            }
        }

        return Array(projectUpdaters.joined())
    }

    fileprivate func startAPIRequests() {
        for project in projectUpdaters {
            project.reset()
        }
    }

    fileprivate func stopAPIRequests() {
        if updatesTimer != nil {
            updatesTimer.invalidate()
            updatesTimer = nil
        }
        for project in projectUpdaters {
            project.stop()
        }
    }
}
