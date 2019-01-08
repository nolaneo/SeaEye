import Foundation

struct CircleCIBuild: Decodable {
    enum Status: String, Decodable {
        case canceled
        case failed
        case fixed
        case infrastructureFail = "infrastructure_fail"
        case noTests = "no_tests"
        case notRun = "not_run"
        case notRunning = "not_running"
        case queued
        case retried
        case running
        case scheduled
        case success
        case timedout
    }

    let branch: String
    let reponame: String
    let status: Status
    let subject: String?
    let authorName: String?
    let buildNum: Int
    let buildUrl: URL
    let startTime: Date?
    var queuedAt: Date?
    var stopTime: Date?
    let workflows: Workflow?
    
    private let initDate: Date = Date.distantPast


    init(branch: String, project: String, status: Status, subject: String, user: String, buildNum: Int, url: URL, date: Date) {
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
    
    func lastUpdateTime() -> Date {
        return [self.startTime, self.queuedAt, self.stopTime, self.initDate].compactMap{ $0 }.max()!
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
