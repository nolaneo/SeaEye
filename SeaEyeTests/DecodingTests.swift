import Cocoa
import XCTest

class DecodingTests: XCTestCase {
    func testDecodeForBuildCircleCI2() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "circleci2-project", ofType: "json")!
        do {
            let data = try NSData(contentsOfFile: path) as Data
            do {
                let decoder = SeaEyeDecoder()
                let build = try decoder.decode(CircleCIBuild.self, from: data)
                XCTAssertEqual(build.branch, "cm-circleci2")
                XCTAssertEqual(build.authorName, "Conor Mongey")
            } catch {
                XCTFail(error.localizedDescription)
            }

        } catch {
            XCTFail("couldn't load file")
        }
    }

    func testDecodingWorkflow() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "circleci-workflow", ofType: "json")!
        do {
            let data = try NSData(contentsOfFile: path) as Data
            do {
                let decoder = SeaEyeDecoder()
                let build = try decoder.decode(CircleCIBuild.self, from: data)
                XCTAssertNotNil(build.workflows)
                XCTAssertEqual(build.workflows!.workflowName, "build-test-lint")
                XCTAssertEqual(build.workflows!.jobName, "swiftlint")
            } catch {
                XCTFail(error.localizedDescription)
            }

        } catch {
            XCTFail("couldn't load file")
        }
    }
}
