//
//  SeaEyeStaus.swift
//  SeaEye
//
//  Created by Eoin Nolan on 16/11/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

import Cocoa

class SeaEyeStatus: NSObject, NSURLConnectionDelegate {
    
    var data = NSMutableData()
    
    override init() {
        super.init()
        //After 60 seconds check for updates
        NSTimer.scheduledTimerWithTimeInterval(
            NSTimeInterval(60),
            target: self,
            selector: Selector("getApplicationStatus"),
            userInfo: nil,
            repeats: false
        )
    }
    
    func getApplicationStatus(){
        let urlPath: String = "https://raw.githubusercontent.com/nolaneo/SeaEye/master/project_status.json"
        var url = NSURL(string: urlPath)
        if let url = url {
            var request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
            var connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)!
        }
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
            self.data,
            options: NSJSONReadingOptions.MutableContainers,
            error: &err
            ) as NSDictionary
        
        if let error = err {
            println("An error occured while parsing the project status from GitHub")
        } else {
            let latestVersionString = json.objectForKey("latest_version") as NSString!
            println("The latest version of SeaEye is: \(latestVersionString)")
            if let info = NSBundle.mainBundle().infoDictionary as NSDictionary! {
                if let currentVersionString = info.objectForKey("CFBundleShortVersionString") as String! {
                    let numberFormatter = NSNumberFormatter()
                    let currentVersionFloat = numberFormatter.numberFromString(currentVersionString)?.floatValue
                    let latestVersionFloat = numberFormatter.numberFromString(latestVersionString)?.floatValue
                    
                    if currentVersionFloat < latestVersionFloat {
                        var info = ["message": "A new version of SeaEye is available (\(latestVersionString))"]
                        NSNotificationCenter.defaultCenter().postNotificationName(
                            "SeaEyeAlert",
                            object: self,
                            userInfo: info
                        )
                    }
                }
            }

        }

    }

}