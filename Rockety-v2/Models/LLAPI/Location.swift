//
//  Location.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 06.08.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation

class Location: Decodable {
    let id: Int?
    let url: String?
    let name: String?
    let countryCode: String?
    let mapImage: String?
    let totalLaunchCount: Int?
    let totalLandingCount: Int?
}
