//
//  SeaEyeWindowSettingsController.swift
//  SeaEye
//
//  Created by Conor Mongey on 26/11/2017.
//  Copyright © 2017 Nolaneo. All rights reserved.
//

import Cocoa

class SeaEyeWindowSettingsController : NSWindowController {
    @IBOutlet weak var apiTokenField: NSTextField!
    
    @IBOutlet weak var table: NSTableView!
    @IBOutlet weak var branchRegex: NSTextField!
    @IBOutlet weak var userRegex: NSTextField!
    var projects: [CircleCIProject]?
    
    @IBAction func save(_ sender: Any) {
        if self.apiTokenField != nil {
            setUserDefaultsFromField(field: apiTokenField, key: "SeaEyeAPIKey")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "SeaEyeSettingsChanged"), object: nil)
        }
        setUserDefaultsFromField(field: branchRegex, key: "SeaEyeBranches")
        setUserDefaultsFromField(field: userRegex, key: "SeaEyeUsers")
        LoadTableData()
    }
    
    func setUserDefaultsFromField(field: NSTextField, key: String) {
        let userDefaults = UserDefaults.standard
        let fieldValue = field.stringValue
        if fieldValue.isEmpty {
            userDefaults.removeObject(forKey: key)
        } else {
            userDefaults.setValue(fieldValue, forKey: key)
        }
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        setField(field: self.apiTokenField, key: "SeaEyeAPIKey")
        setField(field: self.branchRegex, key: "SeaEyeBranches")
        setField(field: self.userRegex, key: "SeaEyeUsers")
        LoadTableData()
    }
    
    func setField(field: NSTextField, key: String) {
        if let f =  UserDefaults.standard.string(forKey: key) {
            field.stringValue = f
        }
        
    }
    func LoadTableData() {
        getProjects(completion: { (r: Result<[CircleCIProject]>) -> Void in
            switch r {
            case .success(let projects):
                print(projects.count)
                self.projects = projects
                self.table.reloadData()
                break
                
            case .failure(let error):
                print("error: \(error.localizedDescription)")
            }
        })
    }
    
    //    override func windowDidLoad() {
//        super.windowDidLoad()
//    }
}

extension SeaEyeWindowSettingsController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if self.projects != nil {
            return self.projects!.count
        } else {
            return 0
        }
    }
}

extension SeaEyeWindowSettingsController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var text: String = ""
        var cellIdentifier: String = ""
        
        print(tableColumn!.title)
        if tableColumn!.title == "Enable" {
            cellIdentifier = "EnableCell"
            text = "enabled?"
        }
        if tableColumn!.title == "Name" {
            cellIdentifier = "NameCell"
            let project = self.projects![row]
            text = "\(project.username)/\(project.reponame)"
        }
        //
        //        // 2
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
    
}
