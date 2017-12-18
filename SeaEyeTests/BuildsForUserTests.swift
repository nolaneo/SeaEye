//
//  BuildsForUserTests.swift
//  SeaEyeTests
//
//  Created by Conor Mongey on 27/11/2017.
//  Copyright © 2017 Nolaneo. All rights reserved.
//

import Cocoa
import XCTest

class BuildsForUserTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBuildsForUser() {
        // This is an example of a functional test case.
        let builds = [CircleCIBuild]()
        let result = buildsForUser(builds: builds, userRegex: nil, branchRegex: nil)
        
        XCTAssertEqual(result.count, 0)
    }

    func testBuildsForUserWithUserRegex() {
        let homerBuild = CircleCIBuild.init(branch: "master",
                                            project: "foobar",
                                            status: "failure",
                                            subject: "wat",
                                            user: "Homer Simpson",
                                            buildNum: 5,
                                            url: URL.init(string: "http://google.com")!,
                                            date: Date())
        let homerDevBuild = CircleCIBuild.init(branch: "dev",
                                            project: "foobar",
                                            status: "failure",
                                            subject: "wat",
                                            user: "Homer Simpson",
                                            buildNum: 5,
                                            url: URL.init(string: "http://google.com")!,
                                            date: Date())
        let bartBuild = CircleCIBuild.init(branch: "master",
                                          project: "foobar",
                                          status: "failure",
                                          subject: "wat",
                                          user: "Bart Simpson",
                                          buildNum: 4,
                                          url: URL.init(string: "http://google.com")!,
                                          date: Date())
        
        let buildsByBart = try! NSRegularExpression(pattern: "^Bart", options: NSRegularExpression.Options.caseInsensitive)
        let buildsByHomer = try! NSRegularExpression(pattern: "^Homer", options: NSRegularExpression.Options.caseInsensitive)
        let masterBuilds = try! NSRegularExpression(pattern: "^master", options: NSRegularExpression.Options.caseInsensitive)

        let result = buildsForUser(builds: [homerBuild], userRegex: buildsByBart, branchRegex: nil)
        XCTAssertEqual(result.count, 0)
        let correctResult = buildsForUser(builds: [homerBuild, bartBuild], userRegex: buildsByHomer, branchRegex: nil)
        XCTAssertEqual(correctResult.count, 1)
        
        let masterResult = buildsForUser(builds: [homerBuild, homerDevBuild, bartBuild], userRegex: nil, branchRegex: masterBuilds)
        XCTAssertEqual(masterResult.count, 2)
        
        let masterHomerResult = buildsForUser(builds: [homerBuild, homerDevBuild, bartBuild], userRegex: buildsByHomer, branchRegex: masterBuilds)
        XCTAssertEqual(masterHomerResult.count, 1)

    }
}
