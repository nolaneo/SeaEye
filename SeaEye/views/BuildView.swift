//
//  BuildView.swift
//  SeaEye
//
//  Created by Eoin Nolan on 27/10/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

import Cocoa

class BuildView: NSTableCellView {
    @IBOutlet var statusColorBox: NSBox!
    @IBOutlet var statusAndSubject: NSTextField!
    @IBOutlet var branchName: NSTextField!
    @IBOutlet var timeAndBuildNumber: NSTextField!
    @IBOutlet var openURLButton: NSButton!
    var url: URL?

    func setupForBuild(build: CircleCIBuild) {
        url = build.buildUrl
        let decorator = BuildDecorator(build: build)

        statusAndSubject.stringValue = decorator.statusAndSubject()
        branchName.stringValue = decorator.branchName()
        timeAndBuildNumber.stringValue = decorator.timeAndBuildNumber()

        if let color = decorator.statusColor() {
            statusAndSubject.textColor = color
            statusColorBox.fillColor = color
        }
    }

    @IBAction func openBuild(_ sender: AnyObject) {
        if url != nil {
            NSWorkspace.shared.open(url!)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "SeaEyeClosePopover"), object: nil)
        }
    }
}
