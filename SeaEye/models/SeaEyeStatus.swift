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
        Timer.scheduledTimer(
            timeInterval: TimeInterval(60),
            target: self,
            selector: #selector(self.getApplicationStatus),
            userInfo: nil,
            repeats: false
        )
    }

    @objc func getApplicationStatus() {
        latestSeaEyeVersion(completion: {(result) in
            switch result {
            case .success(let version):
                self.version = version
                if self.updateAvailable() {
                    self.hasUpdate = true
                    self.notifyOfNewVersion(version: version)
                }

            case .failure:
                break
            }
        })
    }

    func notifyOfNewVersion(version: SeaEyeVersion) {
        print("The latest version of SeaEye is: \(version.latestVersion)")
        let info = [
            "message": "A new version of SeaEye is available (\(version.latestVersion))",
            "url": version.downloadUrl.absoluteString
        ]
        let notification = Notification(name: Notification.Name(rawValue: "SeaEyeAlert"), object: self, userInfo: info)
        NotificationCenter.default.post(notification)
    }

    func updateAvailable() -> Bool {
        if let latestVersion = self.version?.latestVersion.versionNumber() {
            return currentVersion() < latestVersion
        }
        return false
    }

    func currentVersion() -> VersionNumber {
        var version = "0.0"
        if let info = Bundle.main.infoDictionary as NSDictionary! {
            if let currentVersionString = info.object(forKey: "CFBundleShortVersionString") as? String {
                version =  currentVersionString
            }
        }
        return version.versionNumber()
    }
}
