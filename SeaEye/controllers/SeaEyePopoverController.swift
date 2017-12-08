//
//  SeaEyePopoverController.swift
//  SeaEye
//
//  Created by Eoin Nolan on 25/10/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

import Cocoa

class SeaEyePopoverController: NSViewController {

    var clickEventMonitor : AnyObject!
    @IBOutlet weak var subcontrollerView : NSView!
    @IBOutlet weak var openSettingsButton : NSButton!
    @IBOutlet weak var openBuildsButton : NSButton!
    @IBOutlet weak var openUpdatesButton : NSButton!
    @IBOutlet weak var shutdownButton : NSButton!
    @IBOutlet weak var opacityFixView: NSImageView!
    
    var settingsViewController : SeaEyeSettingsController!
    var buildsViewController : SeaEyeBuildsController!
    var updatesViewController : SeaEyeUpdatesController!
    var model : CircleCIModel!
    var applicationStatus : SeaEyeStatus!
    var settingsController: SeaEyeWindowSettingsController!
    let appDelegate = NSApplication.shared.delegate as! AppDelegate
    
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
        setupNavButtons()
        setupViewControllers()
        showUpdateButtonIfAppropriate()
    }
    
    fileprivate func setupViewControllers() {
        let imageFile = isDarkModeEnabled()  ? "opacity-fix-dark" : "opacity-fix-light"
        opacityFixView.image = NSImage(named: NSImage.Name(rawValue: imageFile))
        
        setupNibControllers()
        
        settingsViewController.parent_controller = self
        buildsViewController.model = model
        updatesViewController.applicationStatus = self.applicationStatus
        openBuildsButton.isHidden = true;
        subcontrollerView.addSubview(buildsViewController.view)
    }
    
    fileprivate func setupStoryboardControllers() {
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil);
        settingsViewController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "SeaEyeSettingsController")) as! SeaEyeSettingsController
        buildsViewController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "SeaEyeBuildsController")) as! SeaEyeBuildsController
        updatesViewController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "SeaEyeUpdatesController")) as! SeaEyeUpdatesController
    }
    
    fileprivate func setupNibControllers() {
        settingsViewController = SeaEyeSettingsController(nibName: NSNib.Name(rawValue: "SeaEyeSettingsController"), bundle: nil)
        buildsViewController = SeaEyeBuildsController(nibName: NSNib.Name(rawValue: "SeaEyeBuildsController"), bundle: nil)
        updatesViewController = SeaEyeUpdatesController(nibName: NSNib.Name(rawValue: "SeaEyeUpdatesController"), bundle: nil)
        settingsController = SeaEyeWindowSettingsController(windowNibName: NSNib.Name("SettingsWindow"))
    }
    
    fileprivate func setupNavButtons() {
        //Templated images cause background overlay weirdness
        let imageSuffix = isDarkModeEnabled() ? "" : "-alt"
        
        openSettingsButton.image = NSImage(named: NSImage.Name(rawValue: "settings\(imageSuffix)"))
        openBuildsButton.image = NSImage(named: NSImage.Name(rawValue: "back\(imageSuffix)"))
        shutdownButton.image = NSImage(named: NSImage.Name(rawValue: "power\(imageSuffix)"))
    }
    
    @IBAction func openSettings(_ sender: NSButton) {
        openSettingsButton.isHidden = true
        openUpdatesButton.isHidden = true
        shutdownButton.isHidden = true
        openBuildsButton.isHidden = false
        buildsViewController.view.removeFromSuperview()
        subcontrollerView.addSubview(settingsViewController.view)
//        settingsController.showWindow(self)
    }
    
    @IBAction func openBuilds(_ sender: NSButton) {
        showUpdateButtonIfAppropriate()
        openBuildsButton.isHidden = true;
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
        NSApplication.shared.terminate(self);
    }
    
    fileprivate func showUpdateButtonIfAppropriate() {
        if applicationStatus.hasUpdate {
            let versionString = NSMutableAttributedString(string: applicationStatus.version!.latest_version)
            let range = NSMakeRange(0, applicationStatus.version!.latest_version.count)
            versionString.addAttribute(
                NSAttributedStringKey.foregroundColor,
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
    
    fileprivate func isDarkModeEnabled() -> Bool {
        let dictionary  = UserDefaults.standard.persistentDomain(forName: UserDefaults.globalDomain);
        if let interfaceStyle = dictionary?["AppleInterfaceStyle"] as? NSString {
            return interfaceStyle.localizedCaseInsensitiveContains("dark")
        } else {
            return false
        }
    }
}
