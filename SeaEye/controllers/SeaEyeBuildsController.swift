//
//  SeaEyeBuildsController.swift
//  SeaEye
//
//  Created by Eoin Nolan on 26/10/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

import Cocoa

class SeaEyeBuildsController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    var model : CircleCIModel!
    
    @IBOutlet weak var fallbackView: NSTextField!
    @IBOutlet weak var buildsTable: NSTableView!
    
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(SeaEyeBuildsController.reloadBuilds),
            name: NSNotification.Name(rawValue: "SeaEyeUpdatedBuilds"),
            object: nil
        )
    }
    
    override func viewDidAppear() {
        self.reloadBuilds()
    }
    
    func mavericksSetup() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(SeaEyeBuildsController.reloadBuilds),
            name: NSNotification.Name(rawValue: "SeaEyeUpdatedBuilds"),
            object: nil
        )
        self.reloadBuilds()
    }
    
    override func viewWillDisappear() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func reloadBuilds() {
        print("Reload builds!")
        setupFallBackViews()
        buildsTable.reloadData()
    }
    
    fileprivate func setupFallBackViews() {
        fallbackView.isHidden = false
        buildsTable.isHidden = true
        let userDefaults = UserDefaults.standard
        if  (userDefaults.string(forKey: "SeaEyeAPIKey") == nil) {
            return fallbackView.stringValue = "You have not set an API key"
        }
        if userDefaults.bool(forKey: "SeaEyeError") {
            return fallbackView.stringValue = "Could not connect with your settings. Check'em!"
        }
        if (userDefaults.string(forKey: "SeaEyeOrganization") == nil) {
            return fallbackView.stringValue = "You have not set an organization name"
        }
        if (userDefaults.value(forKey: "SeaEyeProjects") == nil) {
            return fallbackView.stringValue = "You have not added any projects"
        }
        if (model.allBuilds == nil) {
            return fallbackView.stringValue = "Loading Recent Builds"
        }
        if (model.allBuilds.count == 0) {
            return fallbackView.stringValue = "No Recent Builds Found"
        }
        fallbackView.isHidden = true
        buildsTable.isHidden = false
    }
    
    //NSTableViewDataSource
    func numberOfRows(in tableView: NSTableView) -> Int {
        if model != nil && model.allBuilds != nil {
            return model.allBuilds.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var cellView: BuildView = tableView.make(withIdentifier: tableColumn!.identifier, owner: self) as! BuildView
        cellView.setupForBuild(model.allBuilds[row])
        return cellView;
    }
    
    func selectionShouldChange(in tableView: NSTableView) -> Bool {
        return false
    }
}
