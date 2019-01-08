import Foundation

struct Filter: Codable {
    var userFilter: String
    var branchFilter: String

    init(userFilter: String?, branchFilter: String?) {
        self.userFilter = userFilter ?? "*"
        self.branchFilter = branchFilter ?? "*"
    }

    func builds(_ builds: [CircleCIBuild]) -> [CircleCIBuild] {
        return builds.filter({
            self.buildMatches($0)
        })
    }

    private func buildMatches(_ build: CircleCIBuild) -> Bool {
        var matching = true
        if let user = userRegex() {
            let authorName = build.authorName ?? ""

            matching = user.matches(in: authorName,
                                    options: [],
                                    range: NSRange(authorName.startIndex..., in: authorName)).count > 0
        }

        if matching {
            if let branch = branchRegex() {
                matching = branch.matches(in: build.branch,
                                          options: [],
                                          range: NSRange(build.branch.startIndex..., in: build.branch)).count > 0
            }
        }
        return matching
    }
    
    private func branchRegex() -> NSRegularExpression? {
        return try? NSRegularExpression(pattern: branchFilter,
                                        options: NSRegularExpression.Options.caseInsensitive)
    }

    private func userRegex() -> NSRegularExpression? {
        return try? NSRegularExpression(pattern: userFilter,
                                        options: NSRegularExpression.Options.caseInsensitive)
    }
}
