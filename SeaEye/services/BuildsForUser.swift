import Foundation

func buildsForUser(builds: [CircleCIBuild], userRegex: NSRegularExpression?, branchRegex: NSRegularExpression?) -> [CircleCIBuild] {
    return builds.filter({ (build) -> Bool in
        return buildMatches(build: build, userRegex: userRegex, branchRegex: branchRegex)
    })
}

func buildMatches(build: CircleCIBuild, userRegex: NSRegularExpression?, branchRegex: NSRegularExpression?) -> Bool {
    var matching = true
    if userRegex != nil {
        var maybeAuthorName = ""
        if build.author_name != nil {
            maybeAuthorName = build.author_name!
        }
        matching = userRegex!.matches(in: maybeAuthorName, options: [], range: NSRange(maybeAuthorName.startIndex..., in: maybeAuthorName)).count > 0
    }

    if matching && branchRegex != nil {
        matching = branchRegex!.matches(in: build.branch, options: [], range: NSRange(build.branch.startIndex..., in: build.branch)).count > 0
    }
    return matching
}
