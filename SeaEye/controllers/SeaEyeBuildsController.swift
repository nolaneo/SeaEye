//
//  SeaEyeBuildsController.swift
//  SeaEye
//
//  Created by Eoin Nolan on 26/10/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

import Cocoa

class SeaEyeBuildsController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    private var builds: [CircleCIBuild] = []
    var buildsDict: Dictionary<String,CircleCIBuild> = Dictionary()

    @IBOutlet weak var fallbackView: NSTextField!
    @IBOutlet weak var buildsTable: NSTableView!

    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "SeaEyeUpdatedBuilds"),
                                               object: nil,
                                               queue: OperationQueue.main,
                                               using: reloadBuilds)
    }

    override func viewDidAppear() {
        self.reloadBuilds()
    }

    override func viewWillDisappear() {
        NotificationCenter.default.removeObserver(self)
    }

    func reloadBuilds(_: Any? = nil) {
        print("Reload builds!")
        buildsTable?.reloadData()
        if fallbackView != nil {
            setupFallBackViews()
        }
    }

    func regenBuilds() {
        self.builds = Array(buildsDict.values).sorted(by: { (a, b) -> Bool in
            a.lastUpdateTime() > b.lastUpdateTime()
        })
        buildsTable?.reloadData()
    }

    fileprivate func setupFallBackViews() {
        if let fallbackString = FallbackView(settings: Settings.load(), builds: builds).description() {
            fallbackView.stringValue = fallbackString
            fallbackView.isHidden = false
            buildsTable.isHidden = true
        } else {
            fallbackView.isHidden = true
            buildsTable.isHidden = false
        }
    }

    //NSTableViewDataSource
    func numberOfRows(in tableView: NSTableView) -> Int {
        return builds.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cellView: BuildView = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? BuildView {
            cellView.setupForBuild(build: builds[row])
            return cellView
        }
        return nil
    }

    func selectionShouldChange(in tableView: NSTableView) -> Bool {
        return false
    }
}
