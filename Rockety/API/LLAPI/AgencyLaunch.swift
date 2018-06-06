//
//  Launch.swift
//  Rockety
//
//  Created by Antoine Bellanger on 26.05.18.
//  Copyright © 2018 Antoine Bellanger. All rights reserved.
//

import Foundation

struct AgencyMission: Codable {
    
    let total: Int!
    let offset: Int!
    let count: Int!
    
    struct Launch: Codable {
        
        let id: Int!
        let name: String!
        let net: String!
        
        let vidURLs: [String]?
        let infoURLs: [String]?
        let location: Location?
        let rocket: Rocket?
        let missions: [Mission]?
        let lsp: String!
        
        struct Location: Codable {
            let id: Int!
            let name: String!
            let countryCode: String!
            let pads: [Pads]
            
            struct Pads: Codable {
                let id: Int!
                let name: String!
                let latitude: Double!
                let longitude: Double!
            }
        }
        
        struct Rocket: Codable {
            let id: Int!
            let name: String!
            let agencies: [Agency]?
            
            struct Agency: Codable {
                let name: String!
                let countryCode: String!
            }
        }
        
        struct LaunchServiceProvider: Codable {
            let id: Int!
            let name: String!
            let countryCode: String!
        }
        
        struct Mission: Codable {
            let id: Int!
            let name: String!
            let description: String!
            let typeName: String!
        }
        
    }
    
    let launches: [Launch]
}


