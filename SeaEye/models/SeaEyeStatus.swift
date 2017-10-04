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
    var hasUpdate = false
    var changes : String!
    var latestVersion : String!
    var updateURL: URL!
    override init() {
        super.init()
        //After 60 seconds check for updates
        Timer.scheduledTimer(
            timeInterval: TimeInterval(5),
            target: self,
            selector: #selector(SeaEyeStatus.getApplicationStatus),
            userInfo: nil,
            repeats: false
        )
    }

    @objc func getApplicationStatus(){
        let urlPath: String = "https://raw.githubusercontent.com/nolaneo/SeaEye/master/project_status.json"
        let url = URL(string: urlPath)
        if let url = url {
            let request: NSMutableURLRequest = NSMutableURLRequest(url: url)
            var connection: NSURLConnection = NSURLConnection(request: request as URLRequest, delegate: self, startImmediately: true)!
        }
    }
    
    func connection(_ didReceiveResponse: NSURLConnection!, didReceiveResponse response: URLResponse!) {
        self.data = NSMutableData()
    }
    
    func connection(_ connection: NSURLConnection!, didReceiveData data: Data!){
        self.data.append(data)
    }
    
    func connectionDidFinishLoading(_ connection: NSURLConnection!) {
        var err: NSError?
        var json = try? JSONSerialization.jsonObject(
            with: self.data as Data,
            options: JSONSerialization.ReadingOptions.mutableContainers
            ) as! NSDictionary
        
        if let error = err {
            print("An error occured while parsing the project status from GitHub")
        } else {
            let latestVersionString = json?.object(forKey: "latest_version") as! String
            let downloadURLString = json?.object(forKey: "download_url") as! String
         self.updateURL = URL(string: downloadURLString)
            changes = json?.object(forKey: "changes") as! String
            print("The latest version of SeaEye is: \(latestVersionString)")
            print("Changes\n\(changes)")
            if let info = Bundle.main.infoDictionary as NSDictionary! {
                if let currentVersionString = info.object(forKey: "CFBundleShortVersionString") as? String {
                    let numberFormatter = NumberFormatter()
                    let currentVersionFloat = numberFormatter.number(from: currentVersionString)!.floatValue
                    let latestVersionFloat = numberFormatter.number(from: latestVersionString)!.floatValue
                    
                    if currentVersionFloat < latestVersionFloat {
                        hasUpdate = true
                        latestVersion = latestVersionString
                        var info = [
                            "message": "A new version of SeaEye is available (\(latestVersionString))",
                            "url": downloadURLString
                        ]
                        let notification = Notification(name: Notification.Name(rawValue: "SeaEyeAlert"), object: self, userInfo: info)
                        NotificationCenter.default.post(notification)
                    }
                }
            }
        }
    }
}
