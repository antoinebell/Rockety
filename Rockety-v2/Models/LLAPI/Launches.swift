//
//  Launches.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 06.08.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation

class Launches: Decodable {
    let count: Int
    let results: [Launch]
    
    init(count: Int, results: [Launch]) {
        self.count = count
        self.results = results
    }
}

extension Launches {
    func prependLaunches(_ results: [Launch]) -> Launches {
        return Launches(count: self.count + results.count, results: results + self.results)
    }
}
