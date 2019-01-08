import Foundation

class SeaEyeDecoder: JSONDecoder {
    override init() {
        super.init()
        dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
        keyDecodingStrategy = .convertFromSnakeCase
    }
}
