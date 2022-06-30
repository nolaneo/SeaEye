import XCTest
class NewBuildFilterTest: XCTestCase {
    func testItAlsoSortsBuilds() {
        var filter = NewBuildFilter()
        let project = Project.init(vcsProvider: "github",
                                   organisation: "nolaneo",
                                   name: "SeaEye",
                                   filter: nil,
                                   notifySuccess: false,
                                   notifyFailure: false)
        var updatedBuilds = filter.newBuilds(project: project, builds: [])
        let build = CircleCIBuild.init(branch: "master",
                                       project: "ugh",
                                       status: .failed,
                                       subject: "You done goofed",
                                       user: "Mongey",
                                       buildNum: 1,
                                       url: URL.init(string: "http://google.com")!,
                                       date: Date.init(timeIntervalSinceNow: 0))
        let newerBuild = CircleCIBuild.init(branch: "master",
                                       project: "ugh",
                                       status: .success,
                                       subject: "You done goofed",
                                       user: "Mongey",
                                       buildNum: 1,
                                       url: URL.init(string: "http://google.com")!,
                                       date: Date.init(timeIntervalSinceNow: 1))

        updatedBuilds = filter.newBuilds(project: project, builds: [build, newerBuild])
        XCTAssertEqual(updatedBuilds[0].status, newerBuild.status)
        XCTAssertEqual(updatedBuilds[1].status, build.status)
    }

    func testItFiltersBuildsSoWeOnlySeeNewOnes() {
        var filter = NewBuildFilter()
        let project = Project.init(vcsProvider: "github",
                                   organisation: "nolaneo",
                                   name: "SeaEye",
                                   filter: nil,
                                   notifySuccess: false,
                                   notifyFailure: false)
        var updatedBuilds = filter.newBuilds(project: project, builds: [])
        let build = CircleCIBuild.init(branch: "master",
                                       project: "ugh",
                                       status: .failed,
                                       subject: "You done goofed",
                                       user: "Mongey",
                                       buildNum: 1,
                                       url: URL.init(string: "http://google.com")!,
                                       date: Date.init(timeIntervalSinceNow: 0))
        updatedBuilds = filter.newBuilds(project: project, builds: [build])
        XCTAssertEqual(updatedBuilds.count, 1)

        updatedBuilds = filter.newBuilds(project: project, builds: [build])
        XCTAssertEqual(updatedBuilds.count, 0)
    }
}
