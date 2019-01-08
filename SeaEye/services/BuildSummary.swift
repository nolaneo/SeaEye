import Foundation

struct BuildSummary {
    enum Status {
        case running
        case failed
        case success
    }

    let status: Status
    let build: CircleCIBuild?
    let count: Int

    static func generate(builds: [CircleCIBuild]) -> BuildSummary? {
        var failures = 0
        var successes = 0
        var runningBuilds = 0
        var failedBuild: CircleCIBuild?
        var successfulBuild: CircleCIBuild?

        for build in builds {
            switch build.status {
            case .failed: failures += 1; failedBuild = build
            case .timedout: failures += 1; failedBuild = build
            case .success: successes += 1; successfulBuild = build
            case .fixed: successes += 1; successfulBuild = build
            case .running: runningBuilds += 1
            default: break
            }
        }

        if failures > 0 {
            print("Has red build \(String(describing: failedBuild!.subject))")
            return BuildSummary(status: .failed, build: failedBuild!, count: failures)
        }

        if successes > 0 {
            print("Has multiple successes")
            return BuildSummary(status: .success, build: successfulBuild!, count: successes)
        }

        if runningBuilds > 0 {
            print("Has running builds")
            return BuildSummary(status: .running, build: nil, count: runningBuilds)
        }

        return nil
    }
}
