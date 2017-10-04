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
    
    let appDelegate = NSApplication.shared().delegate as! AppDelegate
    
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
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
        
        if isDarkModeEnabled() {
            opacityFixView.image = NSImage(named: "opacity-fix-dark")
        } else {
            opacityFixView.image = NSImage(named: "opacity-fix-light")
        }
        
        setupNibControllers()
        
        settingsViewController.pparent = self
        buildsViewController.model = model
        updatesViewController.applicationStatus = self.applicationStatus
        
        if appDelegate.OS_IS_MAVERICKS_OR_LESS() {
            buildsViewController.mavericksSetup()
        }
        
        openBuildsButton.isHidden = true;
        subcontrollerView.addSubview(buildsViewController.view)
    }
    
    fileprivate func setupStoryboardControllers() {
        
        let storyboard = NSStoryboard(name: "Main", bundle: nil);
        settingsViewController = storyboard.instantiateController(withIdentifier: "SeaEyeSettingsController") as! SeaEyeSettingsController
        buildsViewController = storyboard.instantiateController(withIdentifier: "SeaEyeBuildsController") as! SeaEyeBuildsController
        updatesViewController = storyboard.instantiateController(withIdentifier: "SeaEyeUpdatesController") as! SeaEyeUpdatesController
    }
    
    fileprivate func setupNibControllers() {
        settingsViewController = SeaEyeSettingsController(nibName: "SeaEyeSettingsController", bundle: nil)
        buildsViewController = SeaEyeBuildsController(nibName: "SeaEyeBuildsController", bundle: nil)
        updatesViewController = SeaEyeUpdatesController(nibName: "SeaEyeUpdatesController", bundle: nil)
    }
    
    fileprivate func setupNavButtons() {
        //Templated images cause background overlay weirdness
        if isDarkModeEnabled() {
            openSettingsButton.image = NSImage(named: "settings")
            openBuildsButton.image = NSImage(named: "back")
            shutdownButton.image = NSImage(named: "power")
        } else {
            openSettingsButton.image = NSImage(named: "settings-alt")
            openBuildsButton.image = NSImage(named: "back-alt")
            shutdownButton.image = NSImage(named: "power-alt")
        }
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
        NSApplication.shared().terminate(self);
    }
    
    fileprivate func showUpdateButtonIfAppropriate() {
        if applicationStatus.hasUpdate {
            let versionString = NSMutableAttributedString(string: applicationStatus.latestVersion)
            let range = NSMakeRange(0, applicationStatus.latestVersion.count)
            versionString.addAttribute(
                NSForegroundColorAttributeName,
                value: NSColor.red,
                range: range
            )
            versionString.fixAttributes(in: range)
            openUpdatesButton.attributedTitle = versionString
            openUpdatesButton.isHidden = false
            
            if appDelegate.OS_IS_MAVERICKS_OR_LESS() {
                updatesViewController.setup()
            }
            
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
