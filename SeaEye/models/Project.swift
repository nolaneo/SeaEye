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
    
    var timer: Timer!
    var projectBuilds : Array<Build>!
    var buildsJsonArray : Array<NSDictionary>!
    
    var data = NSMutableData()
    
    func reset() {
        self.stop()
        self.getBuildData()
        timer = Timer.scheduledTimer(
            timeInterval: TimeInterval(30),
            target: self,
            selector: #selector(Project.getBuildData),
            userInfo: nil, repeats: true
        )
    }
    
    func stop() {
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
    }
    
    func getBuildData(){
        let urlPath: String = "https://circleci.com/api/v1/project/" + organizationName + "/" + projectName + "?circle-token=" + apiKey
        let url = URL(string: urlPath)
        if let url = url {
            let request: NSMutableURLRequest = NSMutableURLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            var connection: NSURLConnection = NSURLConnection(request: request as URLRequest, delegate: self, startImmediately: true)!
        } else {
            self.notifyError("Attempted connection to \(urlPath) failed. Please check your settings are correct")
        }

    }
    
    func connection(_ didReceiveResponse: NSURLConnection!, didReceiveResponse response: URLResponse!) {
        self.data = NSMutableData()
    }
    
    func connection(_ connection: NSURLConnection!, didReceiveData data: Data!){
        self.data.append(data)
    }
    
    func connectionDidFinishLoading(_ connection: NSURLConnection!) {
        autoreleasepool {
            let receivedData = NSString(data: self.data as Data, encoding: String.Encoding.utf8.rawValue)

            if self.validateReceivedData(receivedData as String!) {
                var err: NSError?
                var json = try? JSONSerialization.jsonObject(
                    with: self.data as Data,
                    options: JSONSerialization.ReadingOptions.mutableContainers
                    ) as! Array<NSDictionary>
                
                if let error = err {
                    print("An error occured while parsing the json for project \(self.projectName)")
                } else {
                    self.buildsJsonArray = json
                    self.updateBuilds()
                }
            }
        }
    }
    
    fileprivate func validateReceivedData(_ receivedData: String!) -> Bool {
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
                UserDefaults.standard.set(false, forKey: "SeaEyeError")
                return true;
            } else {
                notifyError("The application received an unknown response. There may be network issues.")
                return false;
            }

        } else {
            return false;
        }
    }
    
    fileprivate func notifyError(_ error: String) {
        print(error)
        UserDefaults.standard.set(true, forKey: "SeaEyeError")
        var info = ["message": error]
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: "SeaEyeAlert"),
            object: self,
            userInfo: info
        )
        self.stop()
    }
    
    fileprivate func updateBuilds() {
        var builds = Array<Build>()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        var userRegex : NSRegularExpression!
        var branchRegex : NSRegularExpression!
        if let user = UserDefaults.standard.string(forKey: "SeaEyeUsers") {
            do {
                userRegex = try! NSRegularExpression(pattern: user, options: NSRegularExpression.Options.caseInsensitive)
            }catch {}
        }
        if let branches = UserDefaults.standard.string(forKey: "SeaEyeBranches") {
            do {
            branchRegex = try! NSRegularExpression(pattern: branches,options: NSRegularExpression.Options.caseInsensitive)
            } catch {}
        }
        for (buildJson) in (buildsJsonArray) {
            let build = Build()
            if let branch = buildJson.object(forKey: "branch") as? String {
                build.branch = branch
            }
            if !matchRegex(branchRegex, string: build.branch) {
                continue
            }
            if let user = (buildJson.object(forKey: "user") as AnyObject).object(forKey: "login") as? String {
                build.user = user
            } else if let user = buildJson.object(forKey: "author_name") as? String {
                build.user = user
            }
            if !matchRegex(userRegex, string: build.user) {
                continue
            }
            if let status = buildJson.object(forKey: "status") as? String {
                build.status = status
            }
            if let subject = buildJson.object(forKey: "subject") as? String {
                build.subject = subject
            } else {
                build.subject = build.branch
            }
            if let build_url = buildJson.object(forKey: "build_url") as? String {
                build.url = URL(string: build_url)!
            }
            if let build_num = buildJson.object(forKey: "build_num") as? Int {
                build.buildnum = build_num
            }
            if let reponame = buildJson.object(forKey: "reponame") as? String {
                build.project = reponame
            }
            if let stoptime = buildJson.object(forKey: "stop_time") as? String {
                let date = dateFormatter.date(from: stoptime)
                build.date = (date as! NSDate) as Date!
            } else {
                build.date = Date()
            }
            builds.append(build)
        }
        projectBuilds = builds
        parent.runModelUpdates()
    }
    
    fileprivate func matchRegex(_ regex: NSRegularExpression!, string: String!) -> Bool {
        if regex == nil {
            return true
        }
        let matches = regex.matches(in: string, range: NSMakeRange(0, string.count))
        return matches.count != 0
    }

}
