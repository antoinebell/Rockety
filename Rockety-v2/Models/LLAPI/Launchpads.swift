//
//  Launchpads.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 03.11.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation

struct Launchpads: Decodable {
    let count: Int
    let next: String?
    let results: [Pad]
}

extension Launchpads {
    func prependLaunchpads(_ launchpads: [Pad]) -> Launchpads {
        return Launchpads(count: self.count + launchpads.count, next: self.next, results: launchpads + self.results)
    }
}
