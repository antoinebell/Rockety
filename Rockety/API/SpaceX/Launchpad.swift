//
//  Launchpad.swift
//  Rockety
//
//  Created by Antoine Bellanger on 22.05.18.
//  Copyright © 2018 Antoine Bellanger. All rights reserved.
//

import Foundation

struct Launchpad: Codable {
    let id: String
    let full_name: String
    let status: String
    
    struct Location: Codable {
        let name: String
        let region: String
        let latitude: Double
        let longitude: Double
    }
    
    let location: Location
}
