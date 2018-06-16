//
//  SeaEyeUpdatesController.swift
//  SeaEye
//
//  Created by Eoin Nolan on 17/11/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

import Cocoa

class SeaEyeUpdatesController: NSViewController {

    var applicationStatus: SeaEyeStatus!

    @IBOutlet weak var versionLabel: NSTextField!
    @IBOutlet weak var changes: NSTextField!

    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    func setup() {
        if applicationStatus.version != nil {
            changes.stringValue = applicationStatus.version!.changes
            versionLabel.stringValue = "Version \(applicationStatus.version!.latest_version) Available"
        }
    }

    @IBAction func openUpdatesPage(_ sender: NSButton) {
        if applicationStatus.version != nil {
            NSWorkspace.shared.open(applicationStatus.version!.download_url)
        }
    }

}
