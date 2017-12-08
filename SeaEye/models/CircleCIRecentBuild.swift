import Foundation

struct CircleCIRecentBuild: Decodable{
    let compare : String?
    let oss: Bool
    let committer_date: String?
    let reponame: String
    let fail_reason: String?
    let branch: String
    let why: String
    let username: String
    let vcs_revision: String
    let build_url: String
}
