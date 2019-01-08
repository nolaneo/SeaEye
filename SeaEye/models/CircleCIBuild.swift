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
    let workflows: Workflow?

    init(branch: String, project: String, status: String, subject: String, user: String, buildNum: Int, url: URL, date: Date) {
        self.branch = branch
        self.reponame = project
        self.status = status
        self.subject = subject
        self.authorName = user
        self.buildNum = buildNum
        self.buildUrl = url
        self.startTime = date
        self.workflows = nil
    }
}

struct Workflow: Decodable {
    let jobName: String?
    let jobId: String?
    let workflowID: String?
    let workspaceID: String?
    let upstreamJobIds: [String]?
    let upstreamConcurrencyMap: [String: [String]]?
    let workflowName: String?
}
