//
//  SeaEyeIconController.swift
//  SeaEye
//
//  Created by Eoin Nolan on 25/10/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

import Cocoa

class SeaEyeIconController: NSViewController {

    @IBOutlet weak var iconButton : NSButton!;
    var model = CircleCIModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupMenuBarIcon()
    }
    
    private func setupMenuBarIcon() {
        self.setupStyleNotificationObserver()
        if (self.isDarkModeEnabled()) {
            iconButton.image = NSImage(named: "circleci-normal-alt")
        } else {
            iconButton.image = NSImage(named: "circleci-normal")
        }
    }
    
    private func setupStyleNotificationObserver() {
        NSDistributedNotificationCenter.defaultCenter()
            .addObserver(
                self,
                selector: Selector("alternateIconStyle"),
                name: "AppleInterfaceThemeChangedNotification",
                object: nil
        )
    }
    
    private func isDarkModeEnabled() -> Bool {
        let dictionary  = NSUserDefaults.standardUserDefaults().persistentDomainForName(NSGlobalDomain);
        if let interfaceStyle = dictionary?["AppleInterfaceStyle"] as? NSString {
            return interfaceStyle.localizedCaseInsensitiveContainsString("dark")
        } else {
            return false
        }
    }
    
    func alternateIconStyle() {
        var currentImage = iconButton.image
        if let imageName = currentImage?.name() {
            var alternateImageName : NSString
            if imageName.hasSuffix("-alt") {
                alternateImageName = imageName.stringByReplacingOccurrencesOfString(
                    "-alt",
                    withString: "",
                    options: nil,
                    range: nil
                )
            } else {
                alternateImageName = imageName.stringByAppendingString("-alt")
            }
            iconButton.image = NSImage(named: alternateImageName)
        }
    }
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        if segue.identifier! == "SeaEyeOpenPopoverSegue" {
            self.setupMenuBarIcon()
            let popoverContoller = segue.destinationController as SeaEyePopoverController
            popoverContoller.model = self.model
        }
    }
    
}
