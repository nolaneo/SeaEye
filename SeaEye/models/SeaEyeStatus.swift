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
        println("SeaEyeStatus")
        getApplicationStatus()
    }
    
    func getApplicationStatus(){
        let urlPath: String = "https://raw.githubusercontent.com/nolaneo/SeaEye/master/SeaEye/models/Project.swift"
        var url = NSURL(string: urlPath)
        if let url = url {
            println("start connection")
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
        let receivedData = NSString(data: self.data, encoding: NSUTF8StringEncoding)
        println("Received Data: \(receivedData)")
    }

}