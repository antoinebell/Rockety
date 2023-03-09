//
//  AgencyLauncher.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 25.10.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation

struct AgencyLauncher: Decodable {
    let id: Int?
    let launchLibraryId: RocketId?
    let url: String?
    let name: String
    let family: String?
    let fullName: String?
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
    let consecutiveSuccessfulLaunches: Int?
    let successfulLaunches: Int?
    let failedLaunches: Int?
    let pendingLaunches: Int?
}
