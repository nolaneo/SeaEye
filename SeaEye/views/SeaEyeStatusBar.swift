import Cocoa

struct SeaEyeStatusBar: IconSetter {
    let item: NSStatusItem
    let iconController: SeaEyeIconController

    var state: IconStatus {
        didSet {
            setIcon()
        }
    }

    enum IconStatus: String {
        case idle = "circleci"
        case success = "circleci-success"
        case failure = "circleci-fail"
        case running = "circleci-running"
    }

    init(controller: SeaEyeIconController) {
        self.iconController = controller
        self.item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        self.state = .idle
        setupIcon()
        setIcon()
    }

    func setupIcon() {
        item.target = iconController
        item.action = #selector(SeaEyeIconController.openPopover)
    }

    func setIcon() {
        let statusImage = NSImage.init(named: state.rawValue)
        statusImage?.size = NSSize.init(width: 16, height: 16)
        statusImage?.isTemplate = true

        let iconButton = item.button

        if let tintColor = colorForState(state) {
            iconButton?.image = statusImage?.tinting(with: tintColor)
        } else {
            iconButton?.image = statusImage
        }
    }

    private func colorForState(_ imageName: IconStatus) -> NSColor? {
        switch imageName {
        case .failure:
            return NSColor.systemRed
        case .success:
            return NSColor.systemGreen
        case .running:
            if #available(OSX 10.13, *) {
                return NSColor(named: "GithubYellow")
            } else {
                return NSColor.systemYellow
            }
        case .idle:
            return nil
        }
    }
}
