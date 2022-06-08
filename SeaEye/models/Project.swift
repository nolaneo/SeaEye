import Cocoa

struct Project: Codable, CustomStringConvertible, Identifiable {
    let vcsProvider: String
    let organisation: String
    let name: String
    var filter: Filter?
    var notifySuccess: Bool
    var notifyFailure: Bool

    var path : String {
        return "\(vcsProvider)/\(organisation)/\(name)"
    }
    var id : String {
        return path
    }
    
    var description: String {
        return "\(organisation)/\(name)"
    }
}
