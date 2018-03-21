//
//  CircleCIDecoder.swift
//  SeaEye
//
//  Created by Conor Mongey on 02/12/2017.
//  Copyright © 2017 Nolaneo. All rights reserved.
//

import Foundation

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

class CircleCIDecoder : JSONDecoder{
    override init() {
        super.init()
        self.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
    }
}
