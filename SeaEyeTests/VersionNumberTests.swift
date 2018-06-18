import XCTest

class VersionNumberTests: XCTestCase {
    func testVersionDecode() {
        var versions = ["1.2", "0.4", "0.4-dev", "1.33-dev"]

        let expected = [
            VersionNumber.init(major: 1, minor: 2, development: false),
            VersionNumber.init(major: 0, minor: 4, development: false),
            VersionNumber.init(major: 0, minor: 4, development: true),
            VersionNumber.init(major: 1, minor: 33, development: true)]

            for index in 0...versions.count-1 {
                let result = versions[index].versionNumber()
                if result != expected[index] {
                    XCTFail("Test \(index): \(result) != \(expected[index])")
                }
            }
    }

    func testVersionCompare() {
        var tc1 = VersionNumber.init(major: 1, minor: 1, development: true)
        var tc2 = VersionNumber.init(major: 1, minor: 1, development: false)
        if !(tc1 < tc2) {
            XCTFail("Dev versions should be less than released versions")
        }
        tc1 = VersionNumber.init(major: 0, minor: 10, development: false)
        tc2 = VersionNumber.init(major: 1, minor: 1, development: false)
        if !(tc1 < tc2) {
            XCTFail("Major should be less than Minor")
        }
    }
}
