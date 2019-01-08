import Cocoa
import XCTest

class BuildsForUserTests: XCTestCase {
    func testBuildsForUser() {
        let builds = [CircleCIBuild]()
        let result = buildsForUser(builds: builds, userRegex: nil, branchRegex: nil)

        XCTAssertEqual(result.count, 0)
    }

    func testBuildsForUserWithUserRegex() {
        let homerBuild = CircleCIBuild.init(branch: "master",
                                            project: "foobar",
                                            status: .failed,
                                            subject: "wat",
                                            user: "Homer Simpson",
                                            buildNum: 5,
                                            url: URL.init(string: "http://google.com")!,
                                            date: Date())
        let homerDevBuild = CircleCIBuild.init(branch: "dev",
                                            project: "foobar",
                                            status: .failed,
                                            subject: "wat",
                                            user: "Homer Simpson",
                                            buildNum: 5,
                                            url: URL.init(string: "http://google.com")!,
                                            date: Date())
        let bartBuild = CircleCIBuild.init(branch: "master",
                                          project: "foobar",
                                          status: .failed,
                                          subject: "wat",
                                          user: "Bart Simpson",
                                          buildNum: 4,
                                          url: URL.init(string: "http://google.com")!,
                                          date: Date())

        var buildsByBart, buildsByHomer, masterBuilds: NSRegularExpression?
        do {
            buildsByBart = try NSRegularExpression(pattern: "^Bart", options: NSRegularExpression.Options.caseInsensitive)
        } catch let error{
            XCTFail(error.localizedDescription)
        }
        do {
            buildsByHomer = try NSRegularExpression(pattern: "^Homer", options: NSRegularExpression.Options.caseInsensitive)
        } catch let error{
            XCTFail(error.localizedDescription)
        }
        do {
            masterBuilds = try NSRegularExpression(pattern: "^master", options: NSRegularExpression.Options.caseInsensitive)
        } catch let error{
            XCTFail(error.localizedDescription)
        }

        let result = buildsForUser(builds: [homerBuild], userRegex: buildsByBart, branchRegex: nil)
        XCTAssertEqual(result.count, 0)
        let correctResult = buildsForUser(builds: [homerBuild, bartBuild], userRegex: buildsByHomer, branchRegex: nil)
        XCTAssertEqual(correctResult.count, 1)

        let masterResult = buildsForUser(builds: [homerBuild, homerDevBuild, bartBuild], userRegex: nil, branchRegex: masterBuilds)
        XCTAssertEqual(masterResult.count, 2)

        let masterHomerResult = buildsForUser(builds: [homerBuild, homerDevBuild, bartBuild], userRegex: buildsByHomer, branchRegex: masterBuilds)
        XCTAssertEqual(masterHomerResult.count, 1)

    }
}
