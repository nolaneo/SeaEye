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
    var parent: CircleCIModel!
    
    init(name: String, organization: String, parentModel: CircleCIModel!) {
        projectName = name
        organizationName = organization
        parent = parentModel
    }
    
    var allBuilds : Array<Build>!
    var buildsJsonArray : Array<NSDictionary>!
    
    var data = NSMutableData()
    
    func startConnection(){
        let urlPath: String = "https://circleci.com/api/v1/project/" + organizationName + "/" + projectName + "?circle-token=e11f3ddf1fa3c42b05db6ced01e876ee3735e832"
        var url: NSURL = NSURL(string: urlPath)!
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        var connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)!
    }
    
    func connection(didReceiveResponse: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
        self.data = NSMutableData()
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!){
        self.data.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        var err: NSError?
        var json = NSJSONSerialization.JSONObjectWithData(
            data,
            options: NSJSONReadingOptions.MutableContainers,
            error: &err
            ) as Array<NSDictionary>
        
        if let error = err {
            println("An error occured while parsing the json for project \(projectName)")
        } else {
            println("Loaded the json successfully")
            buildsJsonArray = json
            self.updateBuilds()
        }
        
    }
    
    private func updateBuilds() {
        var builds = Array<Build>()
        for (buildJson) in (buildsJsonArray) {
            let build = Build()
            build.branch  = buildJson.objectForKey("branch") as String!
            build.user    = buildJson.objectForKey("user")?.objectForKey("login") as String!
            build.status  = buildJson.objectForKey("status") as String!
            build.subject = buildJson.objectForKey("subject") as String!
            let url       = buildJson.objectForKey("build_url") as String!
            build.url     = NSURL(string: url)!
            build.buildnum = buildJson.objectForKey("build_num") as Int!
            build.project = buildJson.objectForKey("reponame") as String!
            builds.append(build)
        }
        allBuilds = builds
        parent.updateProjects()
    }

}
