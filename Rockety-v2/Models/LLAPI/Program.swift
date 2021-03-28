//
//  Program.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 25.10.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation

class Program: Decodable {
    let id: Int?
    let name: String?
    let description: String?
    let agencies: [ProgramAgency]?
    let imageUrl: String?
    let infoUrl: String?
    let wikiUrl: String?
}
