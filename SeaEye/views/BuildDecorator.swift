import Foundation
import Cocoa

struct BuildDecorator {
    private var build: CircleCIBuild
    private let seperator = "|"

    init(build: CircleCIBuild) {
        self.build = build
    }

    func branchName() -> String {
        return "\(build.branch) \(seperator) \(build.reponame)"
    }

    func statusAndSubject() -> String {
        if build.status == .noTests {
            return "No tests"
        }

        var status = build.status.rawValue.capitalized

        if let subject = build.subject {
            status += ": \(subject)"
        } else {
            if let workflow = build.workflows {
                status += ": \(workflow.workflowName!) - \(workflow.jobName!)"
            }
        }

        return status
    }

    func statusColor() -> NSColor? {
        switch build.status {
        case .success: return greenColor()
        case .fixed: return greenColor()
        case .noTests: return redColor()
        case .failed: return redColor()
        case .timedout: return redColor()
        case .running: return blueColor()
        case .notRunning: return grayColor()
        case .canceled: return grayColor()
        case .retried: return grayColor()
        case .notRun: return grayColor()
        case .queued: return NSColor.systemPurple
        default:
            print("unknown status" + build.status.rawValue)
            return nil
        }
    }

    func timeAndBuildNumber() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm MMM dd"
        let startTime =  dateFormatter.string(from: build.startTime)
        var result =  startTime + " \(seperator) Build #\(build.buildNum)"
        if build.authorName != nil {
            result += " \(seperator) By \(build.authorName!)"
        }
        return result
    }

    private func greenColor() -> NSColor {
        return NSColor.systemGreen
    }

    private func redColor() -> NSColor {
        return NSColor.systemRed
    }

    private func blueColor() -> NSColor {
        return NSColor.systemBlue
    }

    private func grayColor() -> NSColor {
        return NSColor.systemGray
    }
}
