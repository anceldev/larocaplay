//
//  DateFormatter+Extensions.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 22/12/25.
//

import Foundation

extension DateFormatter {
    static var supabase: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        return dateFormatter
    }()
}
