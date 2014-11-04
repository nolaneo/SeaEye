//
//  Build.swift
//  SeaEye
//
//  Created by Eoin Nolan on 27/10/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

import Cocoa

class Build: NSObject {
    var branch : String!
    var project : String!
    var status : String!
    var subject : String!
    var user : String!
    var buildnum : Int!
    var url : NSURL!
    var date : NSDate!
}
