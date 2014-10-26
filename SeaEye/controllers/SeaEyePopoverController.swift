//
//  SeaEyePopoverController.swift
//  SeaEye
//
//  Created by Eoin Nolan on 25/10/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

import Cocoa

class SeaEyePopoverController: NSViewController {

    var clickEventMonitor : AnyObject!;
    @IBOutlet weak var subcontrollerView : NSView!;
    @IBOutlet weak var openSettingsButton : NSButton!;
    @IBOutlet weak var openBuildsButton : NSButton!;
    
    var settingsViewController : SeaEyeSettingsController!;
    var buildsViewController : SeaEyeBuildsController!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        let storyboard = NSStoryboard(name: "Main", bundle: nil);
        settingsViewController = storyboard?.instantiateControllerWithIdentifier("SeaEyeSettingsController") as SeaEyeSettingsController
        buildsViewController = storyboard?.instantiateControllerWithIdentifier("SeaEyeBuildsController") as SeaEyeBuildsController
        
        openBuildsButton.hidden = true;
        subcontrollerView.addSubview(buildsViewController.view)
    }
    
    @IBAction func openSettings(sender: NSButton) {
        sender.hidden = true
        openBuildsButton.hidden = false
        buildsViewController.view.removeFromSuperview()
        subcontrollerView.addSubview(settingsViewController.view)
    }
    
    @IBAction func openBuilds(sender: NSButton) {
        sender.hidden = true;
        openSettingsButton.hidden = false
        settingsViewController.view.removeFromSuperview()
        subcontrollerView.addSubview(buildsViewController.view)
    }
}
