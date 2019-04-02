import Cocoa
import Foundation

class PreferencesWindowController: NSWindowController {
    var iconController: SeaEyeIconController?

    override init(window: NSWindow?) {
        super.init(window: window)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    init(window: PreferencesWindow?, controller: SeaEyeIconController) {
        self.iconController = controller
        super.init(window: window)
        window?.iconController = controller
    }

    override var windowNibName: NSNib.Name {
        return "PreferencesWindow"
    }

    override func windowDidLoad() {
        print("Prefrences window opened")
        if let preferencesWindow = self.window as? PreferencesWindow {
          preferencesWindow.iconController = iconController
        }
        super.windowDidLoad()
    }
}
