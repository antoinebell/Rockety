//
//  Defaults.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 25.10.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation

struct Defaults {
    static func setEventAddedToCalendar(launchId: Int) {
        UserDefaults.standard.set(true, forKey: "Rocket_Event\(launchId)")
    }
    
    static func getEventAddedToCalendar(launchId: Int) -> Bool? {
        return UserDefaults.standard.bool(forKey: "Rocket_Event\(launchId)")
    }
}
