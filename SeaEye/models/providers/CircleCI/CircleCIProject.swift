//
//  CircleCIProject.swift
//  SeaEye
//
//  Created by Eoin Nolan on 29/03/2015.
//  Copyright (c) 2015 Nolaneo. All rights reserved.
//

import Cocoa

class CircleCIProject: Project, CIProviderInterface {
    
    init(name: String, organization: String, key: String, manager: ProjectManager!) {
        super.init()
        providerName = "CircleCI"
        projectName = name
        apiKey = key
        organizationName = organization
        projectManager = manager
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var buildsJsonArray : Array<NSDictionary>!
    var connection : NSURLConnection!
    
    var data = NSMutableData()
    
    func hasValidSettings() -> Bool {
        return true
    }
    
    func fetchBuilds() {
        self.data.length = 0;
        let urlPath: String = "https://circleci.com/api/v1/project/" + organizationName! + "/" + projectName + "?circle-token=" + apiKey
        var url = NSURL(string: urlPath)
        if let url = url {
            var request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            connection = NSURLConnection(request: request, delegate: self, startImmediately: true)!
        } else {
            self.notifyError("Attempted connection to \(urlPath) failed. Please check your settings are correct")
        }
        
    }
    
    func cancelFetch() {
        connection.cancel()
    }
    
    func connection(didReceiveResponse: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
        self.data = NSMutableData()
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!){
        self.data.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        autoreleasepool {
            let receivedData = NSString(data: self.data, encoding: NSUTF8StringEncoding)
            
            var err: NSError?
            var json: AnyObject? = NSJSONSerialization.JSONObjectWithData(
                self.data,
                options: NSJSONReadingOptions.MutableContainers,
                error: &err
            )
            
            if let error = err {
                println("An error occured while parsing the json for project \(self.projectName)")
            } else if let unwrappedJSON: AnyObject = json {
                let isValid = NSJSONSerialization.isValidJSONObject(unwrappedJSON)
                if !isValid {
                    println("The JSON response for \(self.projectName) is not valid")
                    self.hasError =  true
                }else if let builds = json as? Array<NSDictionary> {
                    self.hasError = false
                    self.buildsJsonArray = builds
                    self.updateBuilds()
                } else {
                    self.hasError = true
                    println("The JSON response for \(self.projectName) was not in the correct format")
                }

            }
        }
    }
    
    private func updateBuilds() {
        var builds = Array<CircleCIBuild>()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        var userRegex : NSRegularExpression!
        var branchRegex : NSRegularExpression!
        if let user = self.userRegexString {
            userRegex = NSRegularExpression(pattern: user,
                options: NSRegularExpressionOptions.CaseInsensitive,
                error: nil
            )
        }
        if let branchRegexString = self.branchRegexString {
            branchRegex = NSRegularExpression(pattern: branchRegexString,
                options: NSRegularExpressionOptions.CaseInsensitive,
                error: nil
            )
        }
        for (buildJson) in (buildsJsonArray) {
            let build = CircleCIBuild()
            if let branch = buildJson.objectForKey("branch") as? String {
                build.branch = branch
            }
            if !matchRegex(branchRegex, string: build.branch) {
                continue
            }
            if let user = buildJson.objectForKey("user")?.objectForKey("login") as? String {
                build.user = user
            } else if let user = buildJson.objectForKey("author_name") as? String {
                build.user = user
            }
            if !matchRegex(userRegex, string: build.user) {
                continue
            }
            if let status = buildJson.objectForKey("status") as? String {
                build.status = status
            }
            if let subject = buildJson.objectForKey("subject") as? String {
                build.subject = subject
            } else {
                build.subject = build.branch
            }
            if let build_url = buildJson.objectForKey("build_url") as? String {
                build.url = NSURL(string: build_url)!
            }
            if let build_num = buildJson.objectForKey("build_num") as? Int {
                build.buildnum = build_num
            }
            if let reponame = buildJson.objectForKey("reponame") as? String {
                build.project = reponame
            }
            if let stoptime = buildJson.objectForKey("stop_time") as? String {
                let date = dateFormatter.dateFromString(stoptime)
                build.date = date
            } else {
                build.date = NSDate()
            }
            builds.append(build)
        }
        projectBuilds = builds
        projectManager.runBuildUpdate()
    }

}
