//
//  CircleCIProject.swift
//  SeaEye
//
//  Created by Eoin Nolan on 29/03/2015.
//  Copyright (c) 2015 Nolaneo. All rights reserved.
//

import Cocoa

class CircleCIProject: Project, CIProviderInterface {
    
    init(name: String, organization: String, key: String, manager: ProviderManager!) {
        providerName = "CircleCI"
        projectName = name
        apiKey = key
        organizationName = organization
        providerManager = manager
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
            timer = nil
        }
    }
    
    private func getBuildData(){
        let urlPath: String = "https://circleci.com/api/v1/project/" + organizationName + "/" + projectName + "?circle-token=" + apiKey
        var url = NSURL(string: urlPath)
        if let url = url {
            var request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            var connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)!
        } else {
            self.notifyError("Attempted connection to \(urlPath) failed. Please check your settings are correct")
        }
        
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
            
            if self.validateReceivedData(receivedData) {
                var err: NSError?
                var json = NSJSONSerialization.JSONObjectWithData(
                    self.data,
                    options: NSJSONReadingOptions.MutableContainers,
                    error: &err
                    ) as Array<NSDictionary>
                
                if let error = err {
                    println("An error occured while parsing the json for project \(self.projectName)")
                } else {
                    self.buildsJsonArray = json
                    self.updateBuilds()
                }
            }
        }
    }
    
    private func validateReceivedData(receivedData: String?) -> Bool {
        if let unwrappedData = receivedData {
            //Circle error messages are returned as a JSON object.
            //If we are expecting an array then we need to handle this case here before parse.
            if unwrappedData.hasPrefix("{") {
                notifyError("No project was found for [\(self.organizationName)/\(self.projectName)] Check your API key is correct.");
                return false;
            }
            
            //If the URL data was wrong then we will receive a HTML page.
            //Check for this case
            if unwrappedData.hasPrefix("<") {
                notifyError("No project was found for [\(self.organizationName)/\(self.projectName)] Check that no invalid characters are included in your project names.")
                return false;
            }
            
            //Ensure the response is a JSON array
            if unwrappedData.hasPrefix("[") && unwrappedData.hasSuffix("]") {
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: "SeaEyeError")
                return true;
            } else {
                notifyError("The application received an unknown response. There may be network issues.")
                return false;
            }
            
        } else {
            return false;
        }
    }
    

    
    private func updateBuilds() {
        var builds = Array<Build>()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        var userRegex : NSRegularExpression!
        var branchRegex : NSRegularExpression!
        if let user = NSUserDefaults.standardUserDefaults().stringForKey("SeaEyeCircleCIUsers") {
            userRegex = NSRegularExpression(pattern: user,
                options: NSRegularExpressionOptions.CaseInsensitive,
                error: nil
            )
        }
        if let branches = NSUserDefaults.standardUserDefaults().stringForKey("SeaEyeCircleCIBranches") {
            branchRegex = NSRegularExpression(pattern: branches,
                options: NSRegularExpressionOptions.CaseInsensitive,
                error: nil
            )
        }
        for (buildJson) in (buildsJsonArray) {
            let build = Build()
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
        parent.runModelUpdates()
    }
    
    private func matchRegex(regex: NSRegularExpression!, string: String!) -> Bool {
        if regex == nil {
            return true
        }
        let matches = regex.matchesInString(string, options: nil, range: NSMakeRange(0, countElements(string)))
        return matches.count != 0
    }
}
