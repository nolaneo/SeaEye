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
    var url : URL!
    
    func setupForBuild(_ value: AnyObject) {
        if let build = value as? Build {
            url = build.url as URL!
            statusAndSubject.stringValue = build.status.capitalized + ": " + build.subject
            switch build.status {
                case "success": setColors(greenColor()); break;
                case "fixed": setColors(greenColor()); break;
                case "failed": setColors(redColor()); break;
                case "timedout": setColors(redColor()); break;
                case "running": setColors(blueColor()); break;
                case "canceled": setColors(grayColor()); break;
                case "retried": setColors(grayColor()); break;
                default: break;
            }
            branchName.stringValue = build.branch
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm MMM dd"
            timeAndBuildNumber.stringValue = dateFormatter.string(from: build.date as Date) + " | Build #\(build.buildnum)"
            
            if isDarkModeEnabled() {
                openURLButton.image = NSImage(named: NSImage.Name(rawValue: "open-alt"))
            }
        }
    }
    
    @IBAction func openBuild(_ sender: AnyObject) {
        if url != nil {
            NSWorkspace.shared.open(url)
        }
    }
    
    fileprivate func setColors(_ color: NSColor) {
        statusAndSubject.textColor = color
        statusColorBox.fillColor = color
        let cell = statusAndSubject.cell as! NSCell
    }
    
    fileprivate func greenColor() -> NSColor {
        if isDarkModeEnabled() {
            return NSColor.green
        } else {
            return NSColorFromRGB(0x229922)
        }
    }
    
    fileprivate func redColor() -> NSColor {
        if isDarkModeEnabled() {
            return NSColorFromRGB(0xff5b5b)
        } else {
            return NSColor.red
        }
    }
    
    fileprivate func blueColor() -> NSColor {
        if isDarkModeEnabled() {
            return NSColorFromRGB(0x00bfff)
        } else {
            return NSColorFromRGB(0x0096c8)
        }
    }
    
    fileprivate func grayColor() -> NSColor {
        if isDarkModeEnabled() {
            return NSColor.lightGray
        } else {
            return NSColor.gray
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
    
    fileprivate func NSColorFromRGB(_ rgbValue: UInt) -> NSColor {
        return NSColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
