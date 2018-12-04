import Foundation

struct ApplicationStartupManager {
    static let bundlePath: String = Bundle.main.bundlePath

    static func toggleLaunchAtStartup() {
        let itemReferences = itemReferencesInLoginItems()
        let shouldBeToggled = (itemReferences.existingReference == nil)
        let loginItemsRef = LSSharedFileListCreate(
            nil,
            kLSSharedFileListSessionLoginItems.takeRetainedValue(),
            nil
        ).takeRetainedValue() as LSSharedFileList?
        if loginItemsRef != nil {
            if shouldBeToggled {
                let appUrl: CFURL = URL(fileURLWithPath: bundlePath) as CFURL

                LSSharedFileListInsertItemURL(
                    loginItemsRef,
                    itemReferences.lastReference,
                    nil,
                    nil,
                    appUrl,
                    nil,
                    nil
                )
                print("Application was added to login items")
            } else {
                if let itemRef = itemReferences.existingReference {
                    LSSharedFileListItemRemove(loginItemsRef, itemRef)
                    print("Application was removed from login items")
                }
            }
        }
    }

    static func applicationIsInStartUpItems() -> Bool {
        return (itemReferencesInLoginItems().existingReference != nil)
    }

    private static func itemReferencesInLoginItems() -> (existingReference: LSSharedFileListItem?, lastReference: LSSharedFileListItem?) {
        let appUrl: URL = URL(fileURLWithPath: bundlePath)
        let loginItemsRef = LSSharedFileListCreate(
            nil,
            kLSSharedFileListSessionLoginItems.takeRetainedValue(),
            nil
        ).takeRetainedValue() as LSSharedFileList?
        if loginItemsRef == nil {
            return (nil, nil)
        }
        // swiftlint:disable force_cast
        let loginItems: [LSSharedFileListItem] = LSSharedFileListCopySnapshot(loginItemsRef, nil).takeRetainedValue() as! [LSSharedFileListItem]
        // swiftlint:enable force_cast
        print("There are \(loginItems.count) login items")
        let lastItemRef: LSSharedFileListItem = loginItems.last!

        for currentItemRef in loginItems {
            if let itemUrl = LSSharedFileListItemCopyResolvedURL(currentItemRef, 0, nil) {
                if (itemUrl.takeRetainedValue() as URL) == appUrl {
                    return (currentItemRef, lastItemRef)
                }
            } else {
                print("Unknown login application")
            }
        }

        // The application was not found in the startup list
        return (nil, lastItemRef)
    }
}
