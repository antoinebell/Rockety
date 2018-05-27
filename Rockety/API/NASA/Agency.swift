//
//  Agency.swift
//  Rockety
//
//  Created by Antoine Bellanger on 26.05.18.
//  Copyright © 2018 Antoine Bellanger. All rights reserved.
//

import Foundation

struct AgencyResult: Codable {
    
    let total: Int!
    let offset: Int!
    let count: Int!
    
    struct Agency: Codable {
        let id: Int!
        let name: String!
        let countryCode: String!
        let abbrev: String!
        let type: Int!
    }
    
    let agencies: [Agency]
}
