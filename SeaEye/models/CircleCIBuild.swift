import Foundation

struct CircleCIBuild: Decodable {
    let branch: String
    let reponame: String
    let status: String
    let subject: String?
    let authorName: String?
    let buildNum: Int
    let buildUrl: URL
    let startTime: Date

    init(branch: String, project: String, status: String, subject: String, user: String, buildNum: Int, url: URL, date: Date) {
        self.branch = branch
        self.reponame = project
        self.status = status
        self.subject = subject
        self.authorName = user
        self.buildNum = buildNum
        self.buildUrl = url
        self.startTime = date
    }
}
