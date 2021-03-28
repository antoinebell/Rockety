//
//  LauncherStage.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 25.10.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation

struct LauncherStage: Decodable {
    let id: Int?
    let type: String?
    let reused: Bool?
    let launcherFlightNumber: Int?
    let launcher: Launcher?
    let landing: Landing?
    let previousFlightDate: Date?
    let turnAroundTimeDays: Int?
    
}
