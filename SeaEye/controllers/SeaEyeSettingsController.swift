//
//  SeaEyeSettingsController.swift
//  SeaEye
//
//  Created by Eoin Nolan on 26/10/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

import Cocoa

class SeaEyeSettingsController: NSViewController {

    var parentController: SeaEyePopoverController!

    @IBOutlet weak var runOnStartup: NSButton!
    @IBOutlet weak var showNotifications: NSButton!

    @IBOutlet weak var apiKeyField: NSTextField!
    @IBOutlet weak var organizationField: NSTextField!
    @IBOutlet weak var projectsField: NSTextField!
    @IBOutlet weak var usersField: NSTextField!
    @IBOutlet weak var branchesField: NSTextField!

    @IBOutlet weak var versionString: NSTextField!

    let appDelegate = NSApplication.shared.delegate
//    let settings = Settings.load()

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
//        let notify = showNotifications.state == .on
//        UserDefaults.standard.set(notify, forKey: SettingsV0.Keys.notify.rawValue)
//        setUserDefaultsFromField(apiKeyField, key: SettingsV0.Keys.apiKey.rawValue)
//        setUserDefaultsFromField(organizationField, key: SettingsV0.Keys.organisation.rawValue)
//        setUserDefaultsFromField(projectsField, key: SettingsV0.Keys.projects.rawValue)
//        setUserDefaultsFromField(branchesField, key: SettingsV0.Keys.branchFilter.rawValue)
//        setUserDefaultsFromField(usersField, key: SettingsV0.Keys.userFilter.rawValue)
//        NotificationCenter.default.post(name: Notification.Name(rawValue: "SeaEyeSettingsChanged"), object: nil)
//        parentController.openBuilds(sender)
    }

    @IBAction func saveNotificationPreferences(_ sender: NSButton) {
        let notify = showNotifications.state == .on
        print("Notificaiton Preference: \(notify)")
//        UserDefaults.standard.set(notify, forKey: SettingsV0.Keys.notify.rawValue)
    }

    @IBAction func saveRunOnStartupPreferences(_ sender: NSButton) {
        print("Changing launch on startup")
        ApplicationStartupManager.toggleLaunchAtStartup()
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
//        if settings.notify {
//            showNotifications.state = NSControl.StateValue.on
//        } else {
//            showNotifications.state = NSControl.StateValue.off
//        }
//        let hasRunOnStartup = ApplicationStartupManager.applicationIsInStartUpItems()
//        if hasRunOnStartup {
//            runOnStartup.state = NSControl.StateValue.on
//        } else {
//            runOnStartup.state = NSControl.StateValue.off
//        }
//        setupFieldFromUserDefaults(apiKeyField, key: SettingsV0.Keys.apiKey.rawValue)
//        setupFieldFromUserDefaults(organizationField, key: SettingsV0.Keys.organisation.rawValue)
//        setupFieldFromUserDefaults(projectsField, key: SettingsV0.Keys.projects.rawValue)
//        setupFieldFromUserDefaults(branchesField, key: SettingsV0.Keys.branchFilter.rawValue)
//        setupFieldFromUserDefaults(usersField, key: SettingsV0.Keys.userFilter.rawValue)
    }

    fileprivate func setupFieldFromUserDefaults(_ field: NSTextField, key: String) {
        let userDefaults = UserDefaults.standard
        if let savedValue = userDefaults.string(forKey: key) {
            field.stringValue = savedValue
        }
    }

    fileprivate func setupVersionNumber() {
        versionString.stringValue = VersionNumber.current().description
    }
}
