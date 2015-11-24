//
//  SeaEyeSettingsController.swift
//  SeaEye
//
//  Created by Eoin Nolan on 26/10/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

import Cocoa

class SeaEyeSettingsController: NSViewController {
    
    var parent : SeaEyePopoverController!
    
    @IBOutlet weak var runOnStartup : NSButton!
    @IBOutlet weak var showNotifications : NSButton!
    
    @IBOutlet weak var apiKeyField : NSTextField!
    @IBOutlet weak var organizationField : NSTextField!
    @IBOutlet weak var projectsField : NSTextField!
    @IBOutlet weak var usersField : NSTextField!
    @IBOutlet weak var branchesField : NSTextField!
    
    @IBOutlet weak var versionString : NSTextField!
    
    let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
    
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVersionNumber()
    }
    
    override func viewWillAppear() {
       setupInputFields()
    }
    
    
    @IBAction func openAPIPage(sender: NSButton) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://circleci.com/account/api")!)
    }
    
    @IBAction func saveUserData(sender: NSButton) {
        let notify = showNotifications.state == NSOnState
        NSUserDefaults.standardUserDefaults().setBool(notify, forKey: "SeaEyeNotify")
        setUserDefaultsFromField(apiKeyField, key: "SeaEyeAPIKey")
        setUserDefaultsFromField(organizationField, key: "SeaEyeOrganization")
        setUserDefaultsFromField(projectsField, key: "SeaEyeProjects")
        setUserDefaultsFromField(branchesField, key: "SeaEyeBranches")
        setUserDefaultsFromField(usersField, key: "SeaEyeUsers")
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "SeaEyeError")
        NSNotificationCenter.defaultCenter().postNotificationName("SeaEyeSettingsChanged", object: nil)
        parent.openBuilds(sender)
    }
    
    @IBAction func saveNotificationPreferences(sender: NSButton) {
        let notify = showNotifications.state == NSOnState
        println("Notificaiton Preference: \(notify)")
        NSUserDefaults.standardUserDefaults().setBool(notify, forKey: "SeaEyeNotify")
    }
    
    @IBAction func saveRunOnStartupPreferences(sender: NSButton) {
        println("Changing launch on startup")
        appDelegate.toggleLaunchAtStartup()
    }
    
    private func setUserDefaultsFromField(field: NSTextField, key: String) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let fieldValue = field.stringValue
        if fieldValue.isEmpty {
            userDefaults.removeObjectForKey(key)
        } else {
            userDefaults.setValue(fieldValue, forKey: key)
        }
    }
    
    private func setupInputFields() {
        let notify = NSUserDefaults.standardUserDefaults().boolForKey("SeaEyeNotify")
        if notify {
            showNotifications.state = NSOnState
        } else {
            showNotifications.state = NSOffState
        }
        let hasRunOnStartup = appDelegate.applicationIsInStartUpItems()
        if hasRunOnStartup {
            runOnStartup.state = NSOnState
        } else {
            runOnStartup.state = NSOffState
        }
        setupFieldFromUserDefaults(apiKeyField, key: "SeaEyeAPIKey")
        setupFieldFromUserDefaults(organizationField, key: "SeaEyeOrganization")
        setupFieldFromUserDefaults(projectsField, key: "SeaEyeProjects")
        setupFieldFromUserDefaults(branchesField, key: "SeaEyeBranches")
        setupFieldFromUserDefaults(usersField, key: "SeaEyeUsers")
    }
    
    private func setupFieldFromUserDefaults(field: NSTextField, key: String) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let savedValue = userDefaults.stringForKey(key) {
            field.stringValue = savedValue
        }
    }
    
    private func setupVersionNumber() {
        if let info = NSBundle.mainBundle().infoDictionary as NSDictionary! {
            if let version = info.objectForKey("CFBundleShortVersionString") as? String {
                versionString.stringValue = "Version \(version)"
            }
        }
    }
}
