//
//  Launch.swift
//  Rockety
//
//  Created by Antoine Bellanger on 26.05.18.
//  Copyright © 2018 Antoine Bellanger. All rights reserved.
//

import Foundation

struct ElseMission: Codable {
    
    let total: Int!
    let offset: Int!
    let count: Int!
    
    struct Launch: Codable {

        let id: Int!
        let name: String!
        let net: String!
        let locationid: Int?
        let rocketid: Int?
        let lsp: String!
    }

    let launches: [Launch]
}


