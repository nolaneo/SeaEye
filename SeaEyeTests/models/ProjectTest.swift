import Foundation
import XCTest

class ProjectTest: XCTestCase {
    func testProjectPath() {
        let project = Project.init(vcsProvider: "github",
                                   organisation: "nolaneo",
                                   name: "SeaEye",
                                   filter: nil,
                                   notifySuccess: false,
                                   notifyFailure: false)

        XCTAssertEqual(project.path(), "github/nolaneo/SeaEye")
    }
}
