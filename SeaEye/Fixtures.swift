//
//  Fixtures.swift
//  SeaEye
//
//  Created by Conor Mongey on 10/04/2021.
//  Copyright © 2021 Nolaneo. All rights reserved.
//

import Foundation

struct Fixtures{
    static var builds : [CircleCIBuild] {
        let failedBuild = CircleCIBuild(branch: "master",
                                       project: "foobar",
                                       status: .failed,
                                       subject: "wat how long does this go.... all the way plz",
                                       user: "Homer Simpson",
                                       buildNum: 5,
                                       url: URL(string: "http://google.com/?s=1")!,
                                       date: Date())
        let queuedBuild = CircleCIBuild(branch: "master",
                                       project: "foobar",
                                       status: .queued,
                                       subject: "wat",
                                       user: "Homer Simpson",
                                       buildNum: 5,
                                       url: URL(string: "http://google.com?s=2")!,
                                       date: Date())
        let succBuild = CircleCIBuild(branch: "master",
                                       project: "foobar",
                                       status: .success,
                                       subject: "wat",
                                       user: "Homer Simpson",
                                       buildNum: 5,
                                       url: URL(string: "http://google.com?s=3")!,
                                       date: Date())
        let cancelledBuild = CircleCIBuild(branch: "master",
                                       project: "foobar",
                                       status: .canceled,
                                       subject: "wat",
                                       user: "Homer Simpson",
                                       buildNum: 5,
                                       url: URL(string: "http://google.com?s=4")!,
                                       date: Date())
        return [failedBuild, queuedBuild, succBuild, cancelledBuild]
    }
}
