//
//  Rocket.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 06.08.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation

class Rocket: Decodable {
    let id: Int?
    let configuration: Configuration?
    let launcherStage: [LauncherStage]?
}
