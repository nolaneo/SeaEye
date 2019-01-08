//
//  NotificationListenerTest.swift
//  SeaEyeTests
//
//  Created by Conor Mongey on 08/01/2019.
//  Copyright © 2019 Nolaneo. All rights reserved.
//

import Foundation
import XCTest
class NotificationListenerTest: XCTestCase {

    func testThings() {
        let sut = NotificationListener.init()
        let failed = CircleCIBuild(branch: "master",
                                   project: "foo/bar",
                                   status: .failed,
                                   subject: "Aint no tests",
                                   user: "Homer",
                                   buildNum: 100,
                                   url: URL.init(string: "https://google.com")!,
                                   date: Date.distantFuture)

        let project = Project.init(vcsProvider: "github",
                                   organisation: "nolaneo",
                                   name: "SeaEye",
                                   filter: nil,
                                   notify: true)


        sut.notify(project:  project, builds: [failed])
    }
}
