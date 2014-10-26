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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clickEventMonitor = NSEvent.addGlobalMonitorForEventsMatchingMask(
            NSEventMask.LeftMouseUpMask|NSEventMask.RightMouseUpMask,
            handler: closePopover
        );
    }
    
    override func viewWillDisappear() {
        NSEvent.removeMonitor(clickEventMonitor);
    }
    
    func closePopover(aEvent: (NSEvent!)) -> Void {
        let presentingController = self.presentingViewController;
        presentingController?.dismissViewController(self);
    }
}
