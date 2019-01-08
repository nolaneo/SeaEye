//
//  SeaEyePopoverController.swift
//  SeaEye
//
//  Created by Eoin Nolan on 25/10/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

import Cocoa

class SeaEyePopoverController: NSViewController, BuildSetter {
    @IBOutlet weak var subcontrollerView: NSView!
    @IBOutlet weak var openSettingsButton: NSButton!
    @IBOutlet weak var openBuildsButton: NSButton!
    @IBOutlet weak var openUpdatesButton: NSButton!
    @IBOutlet weak var shutdownButton: NSButton!

    var settingsViewController: SeaEyeSettingsController!
    var buildsViewController: SeaEyeBuildsController!
    var updatesViewController: SeaEyeUpdatesController!
    var applicationStatus: SeaEyeStatus!
    var appDelegate: NSApplicationDelegate? = NSApplication.shared.delegate
    var heldBuilds = [CircleCIBuild]()

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
        setupViewControllers()
        showUpdateButtonIfAppropriate()
    }
    
    func setBuilds(_ builds: [CircleCIBuild]) {
        guard let buildController = buildsViewController else {
            heldBuilds.append(contentsOf: builds)
            return print("No build controller")
        }

        for build in builds {
            buildController.buildsDict[build.buildUrl.absoluteString] = build
        }

        buildController.regenBuilds()
        buildController.reloadBuilds()
    }

    fileprivate func setupViewControllers() {
        setupNibControllers()

        settingsViewController.parentController = self
        updatesViewController.applicationStatus = self.applicationStatus
        openBuildsButton.isHidden = true
        subcontrollerView.addSubview(buildsViewController.view)
    }

    fileprivate func setupStoryboardControllers() {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        if let sVC = storyboard.instantiateController(withIdentifier: "SeaEyeSettingsController") as? SeaEyeSettingsController {
            settingsViewController = sVC
        }

        if let bVC = storyboard.instantiateController(withIdentifier: "SeaEyeBuildsController") as? SeaEyeBuildsController {
            buildsViewController = bVC
        }
        if let uVC = storyboard.instantiateController(withIdentifier: "SeaEyeUpdatesController") as? SeaEyeUpdatesController {
            updatesViewController = uVC
        }
    }

    fileprivate func setupNibControllers() {
        settingsViewController = SeaEyeSettingsController(nibName: "SeaEyeSettingsController", bundle: nil)
        buildsViewController = SeaEyeBuildsController(nibName: "SeaEyeBuildsController", bundle: nil)
        // If we have builds from client, we hold them until we can push them into the buildViewsController
        if heldBuilds.count > 0 {
            setBuilds(heldBuilds)
            heldBuilds = []
        }
        updatesViewController = SeaEyeUpdatesController(nibName: "SeaEyeUpdatesController", bundle: nil)
    }

    @IBAction func openSettings(_ sender: NSButton) {
        openSettingsButton.isHidden = true
        openUpdatesButton.isHidden = true
        shutdownButton.isHidden = true
        openBuildsButton.isHidden = false
        buildsViewController.view.removeFromSuperview()
        subcontrollerView.addSubview(settingsViewController.view)
    }

    @IBAction func openBuilds(_ sender: NSButton) {
        showUpdateButtonIfAppropriate()
        openBuildsButton.isHidden = true
        shutdownButton.isHidden = false
        openSettingsButton.isHidden = false
        settingsViewController.view.removeFromSuperview()
        updatesViewController.view.removeFromSuperview()
        subcontrollerView.addSubview(buildsViewController.view)
    }

    @IBAction func openUpdates(_ sender: NSButton) {
        openUpdatesButton.isHidden = true
        openSettingsButton.isHidden = true
        shutdownButton.isHidden = true
        openBuildsButton.isHidden = false
        buildsViewController.view.removeFromSuperview()
        subcontrollerView.addSubview(updatesViewController.view)
    }

    @IBAction func shutdownApplication(_ sender: NSButton) {
        NSApplication.shared.terminate(self)
    }

    fileprivate func showUpdateButtonIfAppropriate() {
        if applicationStatus.hasUpdate {
            let versionString = NSMutableAttributedString(string: applicationStatus.version!.latestVersion)
            let range = NSRange(location: 0, length: applicationStatus.version!.latestVersion.count)
            versionString.addAttribute(
                NSAttributedString.Key.foregroundColor,
                value: NSColor.red,
                range: range
            )
            versionString.fixAttributes(in: range)
            openUpdatesButton.attributedTitle = versionString
            openUpdatesButton.isHidden = false

        } else {
            openUpdatesButton.isHidden = true
        }
    }
}
