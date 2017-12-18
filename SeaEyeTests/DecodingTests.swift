//
//  DecodingTests.swift
//  SeaEyeTests
//
//  Created by Conor Mongey on 27/11/2017.
//  Copyright © 2017 Nolaneo. All rights reserved.
//

import Cocoa
import XCTest

class DecodingTests: XCTestCase {
    func testDecodeForBuildCircleCI2() {
        // This is an example of a functional test case.
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "circleci2-project", ofType: "json")!
        do {
            let data = try NSData(contentsOfFile: path) as Data
            do {
                let decoder = CircleCIDecoder()
                let build = try decoder.decode(CircleCIBuild.self, from:data)
                XCTAssertEqual(build.branch, "cm-circleci2")
                XCTAssertEqual(build.author_name, "Conor Mongey")

            } catch  {
                XCTFail(error.localizedDescription)
            }
            
        } catch{
            XCTFail("couldn't load file")
        }
    }   
}
