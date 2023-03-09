//
//  Mission.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 06.08.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation

class Mission: Decodable {
    let id: Int?
    let launchLibraryid: Int?
    let name: String?
    let description: String?
    let launchDesignator: String?
    let type: String?
    let orbit: Orbit?
}
