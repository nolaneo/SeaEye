//
//  SettingsTest.swift
//  SeaEyeTests
//
//  Created by Conor Mongey on 08/01/2019.
//  Copyright © 2019 Nolaneo. All rights reserved.
//

import Foundation
import XCTest

class SettingsTest : XCTestCase {

    func testDefaults() {
        var settings = Settings.load(userDefaults: UserDefaults.init(suiteName: "testing")!)
        XCTAssertFalse(settings.notify)
        XCTAssertFalse(settings.valid())
        settings.apiKey = "abc"
        settings.organization = "nolaneo"
        settings.projectsString = "SeaEye"
        XCTAssertTrue(settings.valid())
    }
}
