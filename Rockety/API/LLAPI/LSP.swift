//
//  LSP.swift
//  Rockety
//
//  Created by Antoine Bellanger on 05.06.18.
//  Copyright © 2018 Antoine Bellanger. All rights reserved.
//

import Foundation

struct LSP: Codable {
    
    let total: Int!
    let offset: Int!
    let count: Int!
    
    let agencies: [Agency]
    
    struct Agency: Codable {
        let id: Int!
        let name: String
        let countryCode: String
        let abbrev: String
        let type: Int
        let infoURL: String?
        let wikiURL: String?
    }
}
