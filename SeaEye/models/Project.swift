//
//  Project.swift
//  SeaEye
//
//  Created by Eoin Nolan on 04/11/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

import Cocoa

protocol CIProviderInterface {
    func fetchBuilds()
    func cancelFetch()
    func hasValidSettings() -> Bool
}

class Project: NSObject, NSURLConnectionDelegate, NSCoding {
    var providerName: String!
    var projectName: String!
    var apiKey: String!
    
    var organizationName: String?
    var userRegexString: String?
    var branchRegexString: String?
    
    var hasError: Bool!
    var projectBuilds: Array<Build>!
    var projectManager: ProjectManager!
    

    func notifyError(error: String) {
        println(error)
        if (!self.hasError) {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "SeaEyeError")
            var info = ["message": error]
            NSNotificationCenter.defaultCenter().postNotificationName(
                "SeaEyeAlert",
                object: self,
                userInfo: info
            )
            hasError = true
        }
    }
    
    func matchRegex(regex: NSRegularExpression!, string: String!) -> Bool {
        if regex == nil {
            return true
        }
        let matches = regex.matchesInString(string, options: nil, range: NSMakeRange(0, countElements(string)))
        return matches.count != 0
    }
    
    override init() {
        
    }

    required init(coder aDecoder: NSCoder) {
        if let providerName = aDecoder.decodeObjectForKey("providerName") as? String {
            self.providerName = providerName
        }
        if let projectName = aDecoder.decodeObjectForKey("projectName") as? String {
            self.projectName = projectName
        }
        if let apiKey = aDecoder.decodeObjectForKey("apiKey") as? String {
            self.apiKey = apiKey
        }
        if let organizationName = aDecoder.decodeObjectForKey("organizationName") as? String {
            self.organizationName = organizationName
        }
        if let userRegexString = aDecoder.decodeObjectForKey("userRegexString") as? String {
            self.userRegexString = userRegexString
        }
        if let branchRegexString = aDecoder.decodeObjectForKey("branchRegexString") as? String {
            self.branchRegexString = branchRegexString
        }
    }
    
     func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(providerName, forKey: "providerName")
        aCoder.encodeObject(projectName, forKey: "projectName")
        aCoder.encodeObject(apiKey, forKey: "apiKey")
        
        if let organizationName = self.organizationName {
            aCoder.encodeObject(organizationName, forKey: "organizationName")
        }
        if let userRegexString = self.userRegexString {
            aCoder.encodeObject(userRegexString, forKey: "userRegexString")
        }
        if let branchRegexString = self.branchRegexString {
            aCoder.encodeObject(branchRegexString, forKey: "branchRegexString")
        }
    }
    
}
