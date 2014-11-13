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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
       self.setupInputFields()
    }
    
    
    @IBAction func openAPIPage(sender: NSButton) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://circleci.com/account/api")!)
    }
    
    @IBAction func saveUserData(sender: NSButton) {
        let notify = showNotifications.state == NSOnState
        NSUserDefaults.standardUserDefaults().setBool(notify, forKey: "SeaEyeNotify")
        self.setUserDefaultsFromField(apiKeyField, key: "SeaEyeAPIKey")
        self.setUserDefaultsFromField(organizationField, key: "SeaEyeOrganization")
        self.setUserDefaultsFromField(projectsField, key: "SeaEyeProjects")
        self.setUserDefaultsFromField(branchesField, key: "SeaEyeBranches")
        self.setUserDefaultsFromField(usersField, key: "SeaEyeUsers")
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "SeaEyeError")
        NSNotificationCenter.defaultCenter().postNotificationName("SeaEyeSettingsChanged", object: nil)
        parent.openBuilds(sender)
    }
    
    @IBAction func saveNotificationPreferences(sender: NSButton) {
        let notify = showNotifications.state == NSOnState
        println("Notificaiton Preference: \(notify)")
        NSUserDefaults.standardUserDefaults().setBool(notify, forKey: "SeaEyeNotify")
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
            self.showNotifications.state = NSOnState
        } else {
            self.showNotifications.state = NSOffState
        }
        self.setupFieldFromUserDefaults(apiKeyField, key: "SeaEyeAPIKey")
        self.setupFieldFromUserDefaults(organizationField, key: "SeaEyeOrganization")
        self.setupFieldFromUserDefaults(projectsField, key: "SeaEyeProjects")
        self.setupFieldFromUserDefaults(branchesField, key: "SeaEyeBranches")
        self.setupFieldFromUserDefaults(usersField, key: "SeaEyeUsers")
    }
    
    private func setupFieldFromUserDefaults(field: NSTextField, key: String) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let savedValue = userDefaults.stringForKey(key) {
            field.stringValue = savedValue
        }
    }
}
