//
//  Pad.swift
//  Rockety
//
//  Created by Antoine Bellanger on 26.05.18.
//  Copyright © 2018 Antoine Bellanger. All rights reserved.
//

import Foundation

struct PadResult: Codable {
    
    let total: Int!
    let offset: Int!
    let count: Int!
    
    struct Pad: Codable {
        let id: Int!
        let name: String!
        let latitude: String!
        let longitude: String!
    }
//
    let pads: [Pad]
}
