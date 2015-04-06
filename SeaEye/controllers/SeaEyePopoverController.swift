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
    var projectManager : ProjectManager!
    var applicationStatus : SeaEyeStatus!
    
    let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
    
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        //Mavericks Workaround
        if appDelegate.OS_IS_MAVERICKS_OR_LESS() {
            for (view) in (self.view.subviews) {
                if let id = view.identifier? {
                    println("Setup: \(id)")
                    switch id {
                    case "SubcontrollerView": subcontrollerView = view as NSView
                    case "OpenSettingsButton": openSettingsButton = view as NSButton
                    case "OpenUpdatesButton": openUpdatesButton = view as NSButton
                    case "OpenBuildsButton": openBuildsButton = view as NSButton
                    case "ShutdownButton": shutdownButton = view as NSButton
                    case "OpacityFixView": opacityFixView = view as NSImageView
                    default: println("Unknown View \(id)")
                    }
                }
            }
            opacityFixView.hidden = true
        }

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
    
    private func setupViewControllers() {
        
        if isDarkModeEnabled() {
            opacityFixView.image = NSImage(named: "opacity-fix-dark")
        } else {
            opacityFixView.image = NSImage(named: "opacity-fix-light")
        }
        
        setupNibControllers()
        
        settingsViewController.parent = self
        buildsViewController.projectManager = projectManager
        updatesViewController.applicationStatus = self.applicationStatus
        
        if appDelegate.OS_IS_MAVERICKS_OR_LESS() {
            buildsViewController.mavericksSetup()
        }
        
        openBuildsButton.hidden = true;
        subcontrollerView.addSubview(buildsViewController.view)
    }
    
    private func setupStoryboardControllers() {
        
        let storyboard = NSStoryboard(name: "Main", bundle: nil);
        settingsViewController = storyboard?.instantiateControllerWithIdentifier("SeaEyeSettingsController") as SeaEyeSettingsController
        buildsViewController = storyboard?.instantiateControllerWithIdentifier("SeaEyeBuildsController") as SeaEyeBuildsController
        updatesViewController = storyboard?.instantiateControllerWithIdentifier("SeaEyeUpdatesController") as SeaEyeUpdatesController
    }
    
    private func setupNibControllers() {
        settingsViewController = SeaEyeSettingsController(nibName: "SeaEyeSettingsController", bundle: nil)
        buildsViewController = SeaEyeBuildsController(nibName: "SeaEyeBuildsController", bundle: nil)
        updatesViewController = SeaEyeUpdatesController(nibName: "SeaEyeUpdatesController", bundle: nil)
    }
    
    private func setupNavButtons() {
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
    
    @IBAction func openSettings(sender: NSButton) {
        openSettingsButton.hidden = true
        openUpdatesButton.hidden = true
        shutdownButton.hidden = true
        openBuildsButton.hidden = false
        buildsViewController.view.removeFromSuperview()
        subcontrollerView.addSubview(settingsViewController.view)
    }
    
    @IBAction func openBuilds(sender: NSButton) {
        showUpdateButtonIfAppropriate()
        openBuildsButton.hidden = true;
        shutdownButton.hidden = false
        openSettingsButton.hidden = false
        settingsViewController.view.removeFromSuperview()
        updatesViewController.view.removeFromSuperview()
        subcontrollerView.addSubview(buildsViewController.view)
    }
    
    @IBAction func openUpdates(sender: NSButton) {
        openUpdatesButton.hidden = true
        openSettingsButton.hidden = true
        shutdownButton.hidden = true
        openBuildsButton.hidden = false
        buildsViewController.view.removeFromSuperview()
        subcontrollerView.addSubview(updatesViewController.view)
    }
    
    @IBAction func shutdownApplication(sender: NSButton) {
        NSApplication.sharedApplication().terminate(self);
    }
    
    private func showUpdateButtonIfAppropriate() {
        if applicationStatus.hasUpdate {
            let versionString = NSMutableAttributedString(string: applicationStatus.latestVersion)
            let range = NSMakeRange(0, countElements(applicationStatus.latestVersion))
            versionString.addAttribute(
                NSForegroundColorAttributeName,
                value: NSColor.redColor(),
                range: range
            )
            versionString.fixAttributesInRange(range)
            openUpdatesButton.attributedTitle = versionString
            openUpdatesButton.hidden = false
            
            if appDelegate.OS_IS_MAVERICKS_OR_LESS() {
                updatesViewController.setup()
            }
            
        } else {
            openUpdatesButton.hidden = true
        }
    }
    
    private func isDarkModeEnabled() -> Bool {
        let dictionary  = NSUserDefaults.standardUserDefaults().persistentDomainForName(NSGlobalDomain);
        if let interfaceStyle = dictionary?["AppleInterfaceStyle"] as? NSString {
            return interfaceStyle.localizedCaseInsensitiveContainsString("dark")
        } else {
            return false
        }
    }
}
