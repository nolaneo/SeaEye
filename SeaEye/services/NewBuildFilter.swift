import Foundation

struct NewBuildFilter {
    var seenProjects: Dictionary<String,Date> = Dictionary()

    mutating func newBuilds(project: Project, builds: [CircleCIBuild]) -> [CircleCIBuild] {
        if seenProjects[project.description] == nil {
            seenProjects[project.description] = Date.distantPast
        }

        let newBuilds = builds.filter { (build) -> Bool in
            build.lastUpdateTime() > seenProjects[project.description]!
        }

        let sortedBuilds = newBuilds.sorted { $0.lastUpdateTime() > $1.lastUpdateTime() }
        let buildsUserCaresAbout = project.filter?.builds(sortedBuilds) ?? sortedBuilds
        if buildsUserCaresAbout.count > 0 {
            seenProjects[project.description] = buildsUserCaresAbout[0].lastUpdateTime()
        }

        return buildsUserCaresAbout
    }
}
