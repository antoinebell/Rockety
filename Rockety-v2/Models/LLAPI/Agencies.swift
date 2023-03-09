//
//  Agencies.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 25.10.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation

struct Agencies: Decodable {
    let count: Int?
    let results: [Agency]
}

extension Agencies {
    func prependAgencies(_ agencies: [Agency]) -> Agencies {
        return Agencies(count: self.count ?? 0 + agencies.count, results: agencies + self.results)
    }
}
