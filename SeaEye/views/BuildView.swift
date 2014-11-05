//
//  BuildView.swift
//  SeaEye
//
//  Created by Eoin Nolan on 27/10/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

import Cocoa

class BuildView: NSTableCellView {
    @IBOutlet var statusColorBox : NSBox!
    @IBOutlet var statusAndSubject : NSTextField!
    @IBOutlet var branchName : NSTextField!
    @IBOutlet var timeAndBuildNumber : NSTextField!
    @IBOutlet var openURLButton : NSButton!
    var url : NSURL!
    
    func setObjectValue(value: AnyObject) {
        if let build = value as? Build {
            url = build.url
            statusAndSubject.stringValue = build.status.capitalizedString + ": " + build.subject
            switch build.status {
                case "success": setColors(greenColor()); break;
                case "fixed": setColors(greenColor()); break;
                case "failed": setColors(redColor()); break;
                case "timed out": setColors(redColor()); break;
                case "running": setColors(blueColor()); break;
                case "canceled": setColors(grayColor()); break;
                default: break;
            }
            branchName.stringValue = build.branch
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "HH:mm MMM dd"
            timeAndBuildNumber.stringValue = dateFormatter.stringFromDate(build.date) + " | Build #\(build.buildnum)"
            
            if isDarkModeEnabled() {
                openURLButton.image = NSImage(named: "open-alt")
            }
        }
    }
    
    @IBAction func openBuild(sender: AnyObject) {
        if url != nil {
            NSWorkspace.sharedWorkspace().openURL(url)
        }
    }
    
    private func setColors(color: NSColor) {
        statusAndSubject.textColor = color
        statusColorBox.fillColor = color
    }
    
    private func greenColor() -> NSColor {
        if isDarkModeEnabled() {
            return NSColor.greenColor()
        } else {
            return NSColorFromRGB(0x229922)
        }
    }
    
    private func redColor() -> NSColor {
        if isDarkModeEnabled() {
            return NSColorFromRGB(0xff5b5b)
        } else {
            return NSColor.redColor()
        }
    }
    
    private func blueColor() -> NSColor {
        if isDarkModeEnabled() {
            return NSColorFromRGB(0x00bfff)
        } else {
            return NSColorFromRGB(0x0096c8)
        }
    }
    
    private func grayColor() -> NSColor {
        if isDarkModeEnabled() {
            return NSColor.lightGrayColor()
        } else {
            return NSColor.grayColor()
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
    
    private func NSColorFromRGB(rgbValue: UInt) -> NSColor {
        return NSColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
