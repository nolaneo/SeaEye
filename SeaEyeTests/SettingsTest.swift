//
//  SettingsTest.swift
//  SeaEyeTests
//
//  Created by Conor Mongey on 08/01/2019.
//  Copyright © 2019 Nolaneo. All rights reserved.
//

import Foundation
import XCTest

class SettingsTest: XCTestCase {
    func testMigrationofV0toV1WhenV1DoesNotExist() {
        let ud = UserDefaults.init(suiteName: UUID().uuidString)!
        let oldSettings = SettingsV0.init(apiKey: "abc123",
                                          organization: "nolaneo",
                                          projectsString: "SeaEye foobar",
                                          branchFilter: "master",
                                          userFilter: nil,
                                          notify: true)
        oldSettings.save(userDefaults: ud)
        XCTAssertNil(ud.string(forKey: Settings.defaultsKey))

        let result = Settings.load(userDefaults: ud)
        XCTAssertEqual(result.clientProjects.count, 1, "Should have been a migration")

        // we now expect to see a value in Settings
        XCTAssertNotNil(ud.string(forKey: Settings.defaultsKey))

        XCTAssertEqual(result.clientProjects[0].client.baseURL, "https://circleci.com")
        XCTAssertEqual(result.clientProjects[0].client.token, "abc123")
        XCTAssertEqual(result.clientProjects[0].projects[0].organisation, "nolaneo")
        XCTAssertEqual(result.clientProjects[0].projects[0].name, "SeaEye")
        XCTAssertEqual(result.clientProjects[0].projects[1].name, "foobar")
    }

    func testLoadingOfSettingsWhenV0AndV1Exist() {
        let ud = UserDefaults.init(suiteName: UUID().uuidString)!
        let oldSettings = SettingsV0.init(apiKey: "abc123",
                                          organization: "nolaneo",
                                          projectsString: "SeaEye foobar",
                                          branchFilter: "master",
                                          userFilter: nil,
                                          notify: true)

        oldSettings.save(userDefaults: ud)
        let newSettings = Settings.init(clientProjects: [])
        newSettings.save(userDefaults: ud)
        XCTAssertNotNil(ud.string(forKey: Settings.defaultsKey))
        let result = Settings.load(userDefaults: ud)
        // we should ignore v0's key, we have v1
        XCTAssertEqual(result.clientProjects.count, 0)
    }
}
