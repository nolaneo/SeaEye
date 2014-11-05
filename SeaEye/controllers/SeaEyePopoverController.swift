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
    @IBOutlet weak var shutdownButton : NSButton!
    @IBOutlet weak var opacityFixView: NSImageView!
    
    var settingsViewController : SeaEyeSettingsController!
    var buildsViewController : SeaEyeBuildsController!
    var model : CircleCIModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavButtons()
        self.setupViewControllers()
        clickEventMonitor = NSEvent.addGlobalMonitorForEventsMatchingMask(
            NSEventMask.LeftMouseUpMask|NSEventMask.RightMouseUpMask,
            handler: closePopover
        )
    }
    
    override func viewWillDisappear() {
        NSEvent.removeMonitor(clickEventMonitor)
    }
    
    func closePopover(aEvent: (NSEvent!)) -> Void {
        let presentingController = self.presentingViewController
        presentingController?.dismissViewController(self)
    }
    
    private func setupViewControllers() {
        if isDarkModeEnabled() {
            opacityFixView.image = NSImage(named: "opacity-fix-dark")
        } else {
            opacityFixView.image = NSImage(named: "opacity-fix-light")
        }
        
        let storyboard = NSStoryboard(name: "Main", bundle: nil);
        settingsViewController = storyboard?.instantiateControllerWithIdentifier("SeaEyeSettingsController") as SeaEyeSettingsController
        buildsViewController = storyboard?.instantiateControllerWithIdentifier("SeaEyeBuildsController") as SeaEyeBuildsController
        
        settingsViewController.parent = self
        buildsViewController.model = model
        
        openBuildsButton.hidden = true;
        subcontrollerView.addSubview(buildsViewController.view)
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
        shutdownButton.hidden = true
        openBuildsButton.hidden = false
        buildsViewController.view.removeFromSuperview()
        subcontrollerView.addSubview(settingsViewController.view)
    }
    
    @IBAction func openBuilds(sender: NSButton) {
        openBuildsButton.hidden = true;
        shutdownButton.hidden = false
        openSettingsButton.hidden = false
        settingsViewController.view.removeFromSuperview()
        subcontrollerView.addSubview(buildsViewController.view)
    }
    
    @IBAction func shutdownApplication(sender: NSButton) {
        NSApplication.sharedApplication().terminate(self);
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
