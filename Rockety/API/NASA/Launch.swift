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
        let lsp: String!
        
        let location: Location!
        let rocket: Rocket!
        
        struct Location: Codable {
            let id: Int!
            let name: String!
            let countryCode: String!
            let pads: [Pads]
            
            struct Pads: Codable {
                let id: Int!
                let name: String!
                let latitude: Float!
                let longitude: Float!
            }
        }
        
        struct Rocket: Codable {
            let id: Int!
            let name: String!
        }
        
    }

    let launches: [Launch]
}


