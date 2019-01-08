//
//  SeaEyeStatusBarListenerTest.swift
//  SeaEyeTests
//
//  Created by Conor Mongey on 08/01/2019.
//  Copyright © 2019 Nolaneo. All rights reserved.
//

import Foundation
import XCTest

class SeaEyeStatusBarListenerTest: XCTestCase {
    struct FakeIcon: IconSetter {
        var state: SeaEyeStatusBar.IconStatus
    }

    func testStateIsChanged() {
        var sut = SeaEyeStatusBarListener.init(statusBar: FakeIcon.init(state: .idle))
        let startTime = Date.distantPast

        let failed = CircleCIBuild(branch: "master",
                              project: "foo/bar",
                              status: .failed,
                              subject: "Aint no tests",
                              user: "Homer",
                              buildNum: 100,
                              url: URL.init(string: "https://google.com")!,
                              date: startTime)

        let project = Project.init(vcsProvider: "github",
                                   organisation: "nolaneo",
                                   name: "SeaEye",
                                   filter: nil,
                                   notify: true)
        sut.notify(project:  project, builds: [failed])

        XCTAssertEqual(sut.statusBar.state, .idle, "Old builds should not effect the status")
        let failed2 = CircleCIBuild(branch: "master",
                                   project: "foo/bar",
                                   status: .failed,
                                   subject: "Aint no tests",
                                   user: "Homer",
                                   buildNum: 100,
                                   url: URL.init(string: "https://google.com")!,
                                   date: Date())
        sut.notify(project:  project, builds: [failed2])
        XCTAssertEqual(sut.statusBar.state, .failure, "Failed builds should set the icon")

        let success = CircleCIBuild(branch: "master",
                                    project: "foo/bar",
                                    status: .success,
                                    subject: "Aint no tests",
                                    user: "Homer",
                                    buildNum: 100,
                                    url: URL.init(string: "https://google.com")!,
                                    date: Date())

        sut.notify(project:  project, builds: [success])
        XCTAssertEqual(sut.statusBar.state, .success, "Successful builds should set the icon")

        sut.notify(project:  project, builds: [])
        XCTAssertEqual(sut.statusBar.state, .success, "The Icon should remain set if there are no builds")
    }
}
