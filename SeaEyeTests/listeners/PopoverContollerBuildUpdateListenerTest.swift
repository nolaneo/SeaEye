import Foundation
import XCTest

class PopoverContollerBuildUpdateListenerTest : XCTestCase {
    class MockBuildSetter: BuildSetter {
        var builds : [CircleCIBuild] = [CircleCIBuild]()

        func setBuilds(_ builds: [CircleCIBuild]) {
            self.builds.append(contentsOf: builds)
            print(self.builds.count)
        }
    }

    func testItSetsAllTheBuilds() {
        let b = MockBuildSetter()
        let sut = PopoverContollerBuildUpdateListener.init(buildSetter: b)

        let old = CircleCIBuild(branch: "master",
                                   project: "foo/bar",
                                   status: .failed,
                                   subject: "Aint no tests",
                                   user: "Homer",
                                   buildNum: 100,
                                   url: URL.init(string: "https://google.com")!,
                                   date: Date.distantPast)
        let new = CircleCIBuild(branch: "master",
                                project: "foo/bar",
                                status: .failed,
                                subject: "Aint no tests",
                                user: "Homer",
                                buildNum: 100,
                                url: URL.init(string: "https://google.com")!,
                                date: Date.distantFuture)

        let project = Project.init(vcsProvider: "github",
                                   organisation: "nolaneo",
                                   name: "SeaEye",
                                   filter: nil,
                                   notify: true)


        sut.notify(project: project, builds: [old, new])

        XCTAssertEqual(b.builds.count, 2, "PopoverController should be set with ALL builds, olds and new.")
    }
}
