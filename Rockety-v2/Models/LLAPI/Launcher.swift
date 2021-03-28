//
//  Launcher.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 25.10.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation

struct Launcher: Decodable {
    let id: Int?
    let details: String?
    let flightProven: Bool?
    let serialNumber: String?
    let status: String?
    let successfulLandings: Int?
    let attemptedLandings: Int?
    let flights: Int?
    let lastLaunchDate: Date?
    let firstLaunchDate: Date?
}
