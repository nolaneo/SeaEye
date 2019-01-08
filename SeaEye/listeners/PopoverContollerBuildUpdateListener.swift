//
//  PopoverContollerBuildUpdateListener.swift
//  SeaEye
//
//  Created by Conor Mongey on 08/01/2019.
//  Copyright © 2019 Nolaneo. All rights reserved.
//

import Foundation

protocol BuildSetter {
    func setBuilds(_ builds: [CircleCIBuild])
}

class PopoverContollerBuildUpdateListener: BuildUpdateListener {
    private let buildSetter: BuildSetter
    var allKnownBuilds: [CircleCIBuild] = []

    init(buildSetter: BuildSetter) {
        self.buildSetter = buildSetter
    }

    func notify(project: Project, builds: [CircleCIBuild]) {
        print("Got \(builds.count) builds from \(project)!")
        buildSetter.setBuilds(builds)
    }
}
