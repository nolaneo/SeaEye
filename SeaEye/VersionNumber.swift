import Foundation

struct VersionNumber: Equatable, CustomStringConvertible, Comparable {
    var major: Int
    var minor: Int
    var development: Bool

    static func current() -> VersionNumber {
        if let info = Bundle.main.infoDictionary as NSDictionary? {
            if let version = info.object(forKey: "CFBundleShortVersionString") as? String {
                return version.versionNumber()
            }
        }
        return VersionNumber.init(major: 0, minor: 0, development: true)
    }

    var description: String {
        var str = "\(major).\(minor)"
        if development {
            str += "-dev"
        }
        return str
    }

    static func < (lhs: VersionNumber, rhs: VersionNumber) -> Bool {
        if lhs.major != rhs.major {
            return lhs.major < rhs.major
        } else if lhs.minor != rhs.minor {
            return lhs.minor < rhs.minor
        } else if lhs.development != rhs.development {
            return lhs.development
        }
        return false
    }
}

extension String {
    func versionNumber() -> VersionNumber {
        let numberFormatter = NumberFormatter()
        var major = 0
        var minor = 0

        let development = self.contains("-dev")
        var withoutDevSuffix = self

        if development {
            withoutDevSuffix = withoutDevSuffix.replacingOccurrences(of: "-dev", with: "")
        }

        let splitVersion = withoutDevSuffix.components(separatedBy: ".")

        if splitVersion.count > 1 {
            if let num = numberFormatter.number(from: splitVersion[0]) {
                major = num.intValue
            }
            if let num = numberFormatter.number(from: splitVersion[1]) {
                minor = num.intValue
            }
        }
        return VersionNumber(major: major, minor: minor, development: development)
    }
}
