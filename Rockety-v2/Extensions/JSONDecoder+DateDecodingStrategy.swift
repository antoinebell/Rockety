//
//  JSONDecoder+DateDecodingStrategy.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 06.08.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation

extension JSONDecoder.DateDecodingStrategy {
    static let iso8601Custom = custom { decoder throws -> Date in
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        if let date = DateFormatter.iso8601.date(from: string) {
            return date
        }
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Date is not in ISO8601 format: \(string)")
    }
}
