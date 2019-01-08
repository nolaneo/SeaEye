//
//  Project.swift
//  SeaEye
//
//  Created by Eoin Nolan on 04/11/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

import Cocoa

struct Project: Codable, CustomStringConvertible {
    let vcsProvider: String
    let organisation: String
    let name: String
    var filter: Filter?
    var notify: Bool

    func path() -> String {
        return "\(vcsProvider)/\(organisation)/\(name)"
    }

    var description: String {
        return "\(organisation)/\(name)"
    }
}

protocol BuildUpdateListener {
    func runModelUpdates()
}

class ProjectUpdater: NSObject {
    private let REFRESH_TIME = 30
    private var timer: Timer!

    var buildListener: BuildUpdateListener
    var projectBuilds: [CircleCIBuild]
    let client: CircleCIClient
    let project : Project

    init(project: Project,
         client: CircleCIClient,
         buildUpdateListener: BuildUpdateListener) {
        self.client = client
        self.project = project
        projectBuilds = []
        buildListener = buildUpdateListener
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
                        selector: #selector(ProjectUpdater.getBuildData),
                        userInfo: nil,
                        repeats: true)
        }
    }

    // gets builds, sets the projectBuilds and notfies the listener.
    @objc func getBuildData(_: Any? = nil) {
        client.getProject(name: project.path(),
                    completion: { (result: Result<[CircleCIBuild]>) -> Void in
                switch result {
                case .success(let builds):
                    self.projectBuilds = self.project.filter?.builds(builds) ?? builds
                    self.buildListener.runModelUpdates()
                    break

                case .failure(let error):
                    print("error: \(error.localizedDescription) \(self.project)")
                    ErrorAlert.display(error.localizedDescription)
                    self.stop()
                }
        })
    }

    func stop() {
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
    }
}
