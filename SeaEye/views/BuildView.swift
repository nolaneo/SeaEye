//
//  BuildView.swift
//  SeaEye
//
//  Created by Eoin Nolan on 27/10/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

import Cocoa

class BuildView: NSTableCellView {
    @IBOutlet var statusColorBox: NSBox!
    @IBOutlet var statusAndSubject: NSTextField!
    @IBOutlet var branchName: NSTextField!
    @IBOutlet var timeAndBuildNumber: NSTextField!
    @IBOutlet var openURLButton: NSButton!
    var url: URL?

    func setupForBuild(build: CircleCIBuild) {
        url = build.buildUrl
        statusAndSubject.stringValue = build.status.rawValue.capitalized

        if build.status == .noTests {
            statusAndSubject.stringValue = "No tests"
        }
        if build.subject != nil {
            statusAndSubject.stringValue += ": \(build.subject!)"
        }
        switch build.status {
        case .success: setColors(greenColor())
        case .fixed: setColors(greenColor())
        case .noTests: setColors(redColor())
        case .failed: setColors(redColor())
        case .timedout: setColors(redColor())
        case .running: setColors(blueColor())
        case .canceled: setColors(grayColor())
        case .retried: setColors(grayColor())
        default:
            print("unknown status" + build.status.rawValue)
        }
        branchName.stringValue = "\(build.branch) | \(build.reponame)"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm MMM dd"
        timeAndBuildNumber.stringValue = dateFormatter.string(from: build.startTime) + " | Build #\(build.buildNum)"

        if build.authorName != nil {
            timeAndBuildNumber.stringValue = dateFormatter.string(from: build.startTime) + " | Build #\(build.buildNum)" + " | By \(build.authorName!)"

        }
    }

    @IBAction func openBuild(_ sender: AnyObject) {
        if url != nil {
            NSWorkspace.shared.open(url!)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "SeaEyeClosePopover"), object: nil)
        }
    }

    fileprivate func setColors(_ color: NSColor) {
        statusAndSubject.textColor = color
        statusColorBox.fillColor = color
    }

    fileprivate func greenColor() -> NSColor {
        return isDarkModeEnabled() ? NSColor.green : NSColorFromRGB(0x229922)
    }

    fileprivate func redColor() -> NSColor {
        return isDarkModeEnabled() ? NSColorFromRGB(0xff5b5b) : NSColor.red
    }

    fileprivate func blueColor() -> NSColor {
        return isDarkModeEnabled() ? NSColorFromRGB(0x00bfff) : NSColorFromRGB(0x0096c8)
    }

    fileprivate func grayColor() -> NSColor {
        return isDarkModeEnabled() ? NSColor.lightGray : NSColor.gray
    }

    fileprivate func isDarkModeEnabled() -> Bool {
        let dictionary  = UserDefaults.standard.persistentDomain(forName: UserDefaults.globalDomain)
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
