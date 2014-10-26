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
        println("alternateIconStyle")
    }
    
}
