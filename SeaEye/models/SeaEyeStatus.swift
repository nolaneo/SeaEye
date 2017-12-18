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
        latestSeaEyeVersion(completion: {(r) in
            switch r {
            case .success(let version):
                self.version = version
                if self.updateAvailable() {
                    self.notifyOfNewVersion(version: version)
                }
                break
            
            case .failure:
                break
            }
        })
    }
    
    func notifyOfNewVersion(version: SeaEyeVersion) {
        print("The latest version of SeaEye is: \(version.latest_version)")
        let info = [
            "message": "A new version of SeaEye is available (\(version.latest_version))",
            "url": version.download_url.absoluteString
        ]
        let notification = Notification(name: Notification.Name(rawValue: "SeaEyeAlert"), object: self, userInfo: info)
        NotificationCenter.default.post(notification)
    }
    
    func updateAvailable() -> Bool {
        if self.version != nil {
            let numberFormatter = NumberFormatter()
            let currentVersionFloat = numberFormatter.number(from: currentVersion())!.floatValue
            let latestVersionFloat = numberFormatter.number(from: self.version!.latest_version)!.floatValue
            return currentVersionFloat < latestVersionFloat
        }
        return false
    }
    
    func currentVersion() -> String {
        var version = "0.0"
        if let info = Bundle.main.infoDictionary as NSDictionary! {
            if let currentVersionString = info.object(forKey: "CFBundleShortVersionString") as? String {
                version =  currentVersionString
            }
        }
        return version
    }
}
