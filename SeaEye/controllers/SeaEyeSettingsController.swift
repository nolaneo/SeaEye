//
//  SeaEyeSettingsController.swift
//  SeaEye
//
//  Created by Eoin Nolan on 26/10/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

import Cocoa

class SeaEyeSettingsController: NSViewController {

    var parent_controller: SeaEyePopoverController!

    @IBOutlet weak var runOnStartup: NSButton!
    @IBOutlet weak var showNotifications: NSButton!

    @IBOutlet weak var apiKeyField: NSTextField!
    @IBOutlet weak var organizationField: NSTextField!
    @IBOutlet weak var projectsField: NSTextField!
    @IBOutlet weak var usersField: NSTextField!
    @IBOutlet weak var branchesField: NSTextField!

    @IBOutlet weak var versionString: NSTextField!

    let appDelegate = NSApplication.shared.delegate as! AppDelegate

    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
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

    @IBAction func openAPIPage(_ sender: NSButton) {
        NSWorkspace.shared.open(URL(string: "https://circleci.com/account/api")!)
    }

    @IBAction func saveUserData(_ sender: NSButton) {
        let notify = showNotifications.state == .on
        UserDefaults.standard.set(notify, forKey: "SeaEyeNotify")
        setUserDefaultsFromField(apiKeyField, key: "SeaEyeAPIKey")
        setUserDefaultsFromField(organizationField, key: "SeaEyeOrganization")
        setUserDefaultsFromField(projectsField, key: "SeaEyeProjects")
        setUserDefaultsFromField(branchesField, key: "SeaEyeBranches")
        setUserDefaultsFromField(usersField, key: "SeaEyeUsers")
        UserDefaults.standard.set(false, forKey: "SeaEyeError")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "SeaEyeSettingsChanged"), object: nil)
        parent_controller.openBuilds(sender)
    }

    @IBAction func saveNotificationPreferences(_ sender: NSButton) {
        let notify = showNotifications.state == .on
        print("Notificaiton Preference: \(notify)")
        UserDefaults.standard.set(notify, forKey: "SeaEyeNotify")
    }

    @IBAction func saveRunOnStartupPreferences(_ sender: NSButton) {
        print("Changing launch on startup")
        appDelegate.toggleLaunchAtStartup()
    }

    fileprivate func setUserDefaultsFromField(_ field: NSTextField, key: String) {
        let userDefaults = UserDefaults.standard
        let fieldValue = field.stringValue
        if fieldValue.isEmpty {
            userDefaults.removeObject(forKey: key)
        } else {
            userDefaults.setValue(fieldValue, forKey: key)
        }
    }

    fileprivate func setupInputFields() {
        let notify = UserDefaults.standard.bool(forKey: "SeaEyeNotify")
        if notify {
            showNotifications.state = NSControl.StateValue.on
        } else {
            showNotifications.state = NSControl.StateValue.off
        }
        let hasRunOnStartup = appDelegate.applicationIsInStartUpItems()
        if hasRunOnStartup {
            runOnStartup.state = NSControl.StateValue.on
        } else {
            runOnStartup.state = NSControl.StateValue.off
        }
        setupFieldFromUserDefaults(apiKeyField, key: "SeaEyeAPIKey")
        setupFieldFromUserDefaults(organizationField, key: "SeaEyeOrganization")
        setupFieldFromUserDefaults(projectsField, key: "SeaEyeProjects")
        setupFieldFromUserDefaults(branchesField, key: "SeaEyeBranches")
        setupFieldFromUserDefaults(usersField, key: "SeaEyeUsers")
    }

    fileprivate func setupFieldFromUserDefaults(_ field: NSTextField, key: String) {
        let userDefaults = UserDefaults.standard
        if let savedValue = userDefaults.string(forKey: key) {
            field.stringValue = savedValue
        }
    }

    fileprivate func setupVersionNumber() {
        if let info = Bundle.main.infoDictionary as NSDictionary! {
            if let version = info.object(forKey: "CFBundleShortVersionString") as? String {
                versionString.stringValue = "Version \(version)"
            }
        }
    }
}
