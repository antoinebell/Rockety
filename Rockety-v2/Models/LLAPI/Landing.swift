//
//  Landing.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 25.10.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation

struct Landing: Decodable {
    let id: Int?
    let attempt: Bool?
    let success: Bool?
    let description: String?
    let location: Location?
    let type: LandingType?
    
    struct Location: Decodable {
        let id: Int?
        let name: String?
        let abbrev: String?
        let description: String?
        let successfulLandings: Int?
    }
    
    struct LandingType: Decodable {
        let id: Int?
        let name: String?
        let abbrev: String?
        let description: String?
    }
}
