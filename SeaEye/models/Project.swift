//
//  Project.swift
//  SeaEye
//
//  Created by Eoin Nolan on 04/11/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

import Cocoa

protocol CIProviderInterface {
    func updateBuilds() -> [Build]
    func cancelBuildsUpdate()
    func hasValidSettings() -> Bool
    func setUserRegex(regex: String)
    func setBuildsRegex(regex: String)
}

class Project: NSObject, NSURLConnectionDelegate {
    var providerName: String!
    var projectName: String!
    var organizationName: String!
    var apiKey: String!
    var providerManager: ProviderManager!
    var userRegex: String?
    var buildsRegex: String?

    private func notifyError(error: String) {
        println(error)
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "SeaEyeError")
        var info = ["message": error]
        NSNotificationCenter.defaultCenter().postNotificationName(
            "SeaEyeAlert",
            object: self,
            userInfo: info
        )
        self.stop()
    }
    
}
