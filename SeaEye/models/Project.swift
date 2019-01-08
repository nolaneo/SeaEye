import Cocoa

struct Project: Codable, CustomStringConvertible {
    let vcsProvider: String
    let organisation: String
    let name: String
    var filter: Filter?
    var notify: Bool

    func path() -> String {
        return "\(vcsProvider)/\(organisation)/\(name)"
    }

    var description: String {
        return "\(organisation)/\(name)"
    }
}
