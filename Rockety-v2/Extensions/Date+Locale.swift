//
//  Date+Locale.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 06.08.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//
//  Source: https://stackoverflow.com/questions/28332946/how-do-i-get-the-current-date-in-short-format-in-swift

import Foundation

extension Date {
    func localizedDescription(dateStyle: DateFormatter.Style = .medium,
                              timeStyle: DateFormatter.Style = .medium,
                              in timeZone: TimeZone = .current,
                              locale: Locale = .current) -> String {
        Formatter.date.locale = locale
        Formatter.date.timeZone = timeZone
        Formatter.date.dateStyle = dateStyle
        Formatter.date.timeStyle = timeStyle
        Formatter.date.calendar = Calendar.init(identifier: .gregorian)
        return Formatter.date.string(from: self)
    }

    func formattedLocalizedDescription(withFormat format: String) -> String {
        let dateFormat = DateFormatter.dateFormat(fromTemplate: format, options: 0, locale: .current) ?? format
        Formatter.date.dateFormat = dateFormat
        return Formatter.date.string(from: self)
    }
}

extension TimeZone {
    static let gmt = TimeZone(secondsFromGMT: 0)!
}

extension Formatter {
    static let date = DateFormatter()
}
