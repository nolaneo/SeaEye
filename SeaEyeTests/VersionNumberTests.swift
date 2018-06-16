import XCTest

class VersionNumberTests: XCTestCase {
    func testVersionDecode() {
        var versions = ["1.2", "0.4", "0.4-dev", "1.33-dev"]

        let expected = [
            VersionNumber.init(major: 1, minor: 2, development: false),
            VersionNumber.init(major: 0, minor: 4, development: false),
            VersionNumber.init(major: 0, minor: 4, development: true),
            VersionNumber.init(major: 1, minor: 33, development: true)]

            for i in 0...versions.count-1 {
                let result = versions[i].versionNumber()
                if result != expected[i] {
                    XCTFail("Test \(i): \(result) != \(expected[i])")
                }
            }
    }

    func testVersionCompare() {
        var a = VersionNumber.init(major: 1, minor: 1, development: true)
        var b = VersionNumber.init(major: 1, minor: 1, development: false)
        if !(a < b) {
            XCTFail("Dev versions should be less than released versions")
        }
        a = VersionNumber.init(major: 0, minor: 10, development: false)
        b = VersionNumber.init(major: 1, minor: 1, development: false)
        if !(a < b) {
            XCTFail("Major should be less than Minor")
        }
    }
}
