import Foundation
import Cocoa

struct SelectedServerView {
    var apiServerApiPath: NSTextField!
    var apiServerAuthToken: NSTextField!
    var apiServerTestButton: NSButton!

    func fill(client: CircleCIClient) {
        apiServerApiPath.stringValue = client.baseURL
        apiServerAuthToken.stringValue = client.token
        apiServerTestButton.isEnabled = !client.token.isEmpty
    }
}
