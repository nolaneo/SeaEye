import Foundation

struct ClientProject: Codable {
    var client: CircleCIClient
    var projects: [Project]
}
