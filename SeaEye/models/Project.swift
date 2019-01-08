//
//  Project.swift
//  SeaEye
//
//  Created by Eoin Nolan on 04/11/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

import Cocoa

class Project: NSObject {
    let REFRESH_TIME = 30

    var projectName: String
    var organizationName: String
    var apiKey: String!
    var parent: CircleCIModel!
    var timer: Timer!
    var projectBuilds: [CircleCIBuild]

    init(name: String, organization: String, key: String, parentModel: CircleCIModel!) {
        projectBuilds = []
        projectName = name
        apiKey = key
        organizationName = organization
        parent = parentModel
    }

    func reset() {
        self.stop()
        self.getBuildData()
        if #available(OSX 10.12, *) {
            timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(REFRESH_TIME), repeats: true, block: self.getBuildData(_:))
        } else {
            timer = Timer.scheduledTimer(
                        timeInterval: TimeInterval(REFRESH_TIME),
                        target: self,
                        selector: #selector(Project.getBuildData),
                        userInfo: nil,
                        repeats: true)
        }
    }

    func stop() {
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
    }

    @objc func getBuildData(_: Any? = nil) {
        CircleCIClient.init().getProject(name: "github/\(organizationName)/\(projectName)",
                   completion: { (result: Result<[CircleCIBuild]>) -> Void in
                switch result {
                case .success(let builds):
                    let settings = Settings.load()
                    do {
                        let branchString = settings.branchFilter
                        let userString = settings.userFilter
                        var branchRegex: NSRegularExpression?
                        var userRegex: NSRegularExpression?

                        if userString != nil {
                            print("Using regex \(userString!) for user")
                            userRegex = try NSRegularExpression(pattern: userString!, options: NSRegularExpression.Options.caseInsensitive)
                        }

                        if branchString != nil {
                            branchRegex = try NSRegularExpression(pattern: branchString!, options: NSRegularExpression.Options.caseInsensitive)
                        }

                        self.projectBuilds = buildsForUser(builds: builds, userRegex: userRegex, branchRegex: branchRegex)
                    } catch {
                         self.projectBuilds = builds
                    }
                    self.parent.runModelUpdates()
                    break

                case .failure(let error):
                    print("error: \(error.localizedDescription) \(self.organizationName) \(self.projectName)")
//                    self.notifyError(error.localizedDescription)
                }
        })
    }

    private func notifyError(_ error: String) {
        print(error)
        let info = ["message": error]
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: "SeaEyeAlert"),
            object: self,
            userInfo: info
        )
        self.stop()
    }
}
