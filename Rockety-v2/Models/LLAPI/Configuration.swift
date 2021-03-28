//
//  Configuration.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 06.08.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation

class Configuration: Decodable {
    let id: Int?
    let launchLibraryId: RocketId?
    let url: String?
    let name: String
    let family: String?
    let fullName: String?
    let manufacturer: Agency?
    let program: [Program]?
    let variant: String?
    let minStage: Int?
    let maxStage: Int?
    let length: Double?
    let diameter: Double?
    let launchMass: Double?
    let leoCapacity: Double?
    let gtoCapacity: Double?
    let toThrust: Double?
    let apogee: Double?
    let totalLaunchCount: Int?
    let consecutiveSuccessfulLaunches: Int?
    let failedLaunches: Int?
    let pendingLaunches: Int?
}
