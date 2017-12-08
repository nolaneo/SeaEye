import Foundation

struct CircleCIProject: Decodable {
    let username: String
    let reponame: String
    let vcs_url: String
    let following: Bool
}
