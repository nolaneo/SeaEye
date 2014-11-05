//
//  Project.swift
//  SeaEye
//
//  Created by Eoin Nolan on 04/11/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

import Cocoa

class Project: NSObject, NSURLConnectionDelegate {
    
    var projectName: String!
    var organizationName: String!
    var apiKey: String!
    var parent: CircleCIModel!
    
    init(name: String, organization: String, key: String, parentModel: CircleCIModel!) {
        projectName = name
        apiKey = key
        organizationName = organization
        parent = parentModel
    }
    
    var timer: NSTimer!
    var projectBuilds : Array<Build>!
    var buildsJsonArray : Array<NSDictionary>!
    
    var data = NSMutableData()
    
    func reset() {
        self.stop()
        self.getBuildData()
        timer = NSTimer.scheduledTimerWithTimeInterval(
            NSTimeInterval(30),
            target: self,
            selector: Selector("getBuildData"),
            userInfo: nil, repeats: true
        )
    }
    
    func stop() {
        if timer != nil {
            timer.invalidate()
        }
    }
    
    func getBuildData(){
        let urlPath: String = "https://circleci.com/api/v1/project/" + organizationName + "/" + projectName + "?circle-token=" + apiKey
        var url = NSURL(string: urlPath)
        if let url = url {
            var request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            var connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)!
        } else {
            println("The url string was fucked up: \(urlPath)")
            stop()
        }

    }
    
    func connection(didReceiveResponse: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
        self.data = NSMutableData()
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!){
        self.data.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        let receivedData = NSString(data: data, encoding: NSUTF8StringEncoding)
        if receivedData? == "{\"message\":\"Couldn't find project at GitHub.\"}" {
            println("No project was found for \(projectName). Check your API key is correct.")
            var info = ["errorMessage": "No project was found for \(organizationName)/\(projectName). Check your API key is correct."]
            NSNotificationCenter.defaultCenter().postNotificationName(
                "SeaEyeAlert",
                object: self,
                userInfo: info
            )
            return self.stop()
        }
        var err: NSError?
        var json = NSJSONSerialization.JSONObjectWithData(
            data,
            options: NSJSONReadingOptions.MutableContainers,
            error: &err
            ) as Array<NSDictionary>
        
        if let error = err {
            println("An error occured while parsing the json for project \(projectName)")
        } else {
            println("Loaded the json successfully for project \(projectName)")
            buildsJsonArray = json
            self.updateBuilds()
        }
        
    }
    
    private func updateBuilds() {
        var builds = Array<Build>()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        for (buildJson) in (buildsJsonArray) {
            let build = Build()
            if let branch = buildJson.objectForKey("branch") as? String {
                build.branch = branch
            }
            if let user = buildJson.objectForKey("user")?.objectForKey("login") as? String {
                build.user = user
            } else if let user = buildJson.objectForKey("author_name") as? String {
                build.user = user
            }
            if let status = buildJson.objectForKey("status") as? String {
                build.status = status
            }
            if let subject = buildJson.objectForKey("subject") as? String {
                build.subject = subject
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
        parent.runModelUpdates()
    }

}
