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
    let client = CircleCIClient.init()

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
        client.getProject(name: "github/\(organizationName)/\(projectName)",
                    completion: { (result: Result<[CircleCIBuild]>) -> Void in
                switch result {
                case .success(let builds):
                    let settings = Settings.load()
                    let f = Filter.init(userFilter: settings.userFilter, branchFilter: settings.branchFilter)
                    self.projectBuilds = f.builds(builds)
                    self.parent.runModelUpdates()
                    break

                case .failure(let error):
                    print("error: \(error.localizedDescription) \(self.organizationName) \(self.projectName)")
                    ErrorAlert.display(error.localizedDescription)
                    self.stop()
                }
        })
    }
}
