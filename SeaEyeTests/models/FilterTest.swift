import Cocoa
import XCTest

class FilterTest: XCTestCase {
    func testBuildsForUserWithUserRegex() {
        let homerBuild = CircleCIBuild(branch: "master",
                                       project: "foobar",
                                       status: .failed,
                                       subject: "wat",
                                       user: "Homer Simpson",
                                       buildNum: 5,
                                       url: URL(string: "http://google.com")!,
                                       date: Date())
        let homerDevBuild = CircleCIBuild(branch: "dev",
                                          project: "foobar",
                                          status: .failed,
                                          subject: "wat",
                                          user: "Homer Simpson",
                                          buildNum: 5,
                                          url: URL(string: "http://google.com")!,
                                          date: Date())
        let bartBuild = CircleCIBuild(branch: "master",
                                      project: "foobar",
                                      status: .failed,
                                      subject: "wat",
                                      user: "Bart Simpson",
                                      buildNum: 4,
                                      url: URL(string: "http://google.com")!,
                                      date: Date())

        // All Barts builds
        var filter = Filter.init(userFilter: "^Bart", branchFilter: nil)
        var result = filter.builds([homerBuild])
        XCTAssertEqual(result.count, 0)

        // All Homers builds
        filter = Filter.init(userFilter: "^Homer", branchFilter: nil)
        result = filter.builds([homerBuild, bartBuild])
        XCTAssertEqual(result.count, 1)

        // All master builds
        filter = Filter.init(userFilter: nil, branchFilter: "master")
        result = filter.builds([homerBuild, homerDevBuild, bartBuild])
        XCTAssertEqual(result.count, 2)

        // All Homers builds on master
        filter = Filter.init(userFilter: "^Homer", branchFilter: "master")
        result = filter.builds([homerBuild, homerDevBuild, bartBuild])
        XCTAssertEqual(result.count, 1)
    }
}
