//
//  SeaEyeStaus.swift
//  SeaEye
//
//  Created by Eoin Nolan on 16/11/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

import Cocoa

class SeaEyeStatus: NSObject {
    var hasUpdate = false
    var version: SeaEyeVersion?

    override init() {
        super.init()
        self.getApplicationStatus()
        Timer.scheduledTimer(
            timeInterval: TimeInterval(60),
            target: self,
            selector: #selector(self.getApplicationStatus),
            userInfo: nil,
            repeats: false
        )
    }

    @objc func getApplicationStatus() {
        GithubClient.latestRelease { (result) in
            switch result {
            case .success(let latestRelease):
                let updateAvailable = VersionNumber.current() < latestRelease.version()
                print("Update: \(updateAvailable). Current \(VersionNumber.current()) |  \(latestRelease.version())")
                if updateAvailable {
                    self.hasUpdate = true
                    self.notifyOfNewVersion(version: latestRelease.toSeaEye())
                }
            case .failure:
                print("Failed to get version")
            }
        }

    }

    func notifyOfNewVersion(version: SeaEyeVersion) {
        self.version = version
        print("The latest version of SeaEye is: \(version.latestVersion)")
        UpdateAvailableNotification.display(version: version)
        self.hasUpdate = true
    }
}
