//
//  Payload.swift
//  Rockety
//
//  Created by Antoine Bellanger on 12.06.18.
//  Copyright © 2018 Antoine Bellanger. All rights reserved.
//

import Foundation

enum Payloads: String {
    case payload_0
    case payload_1
    case payload_2
    case payload_3
    case payload_4
    case payload_5
    case payload_6
    case payload_7
    case payload_8
    case payload_9
    
    case notAvailable
    
    func type() -> String {
        switch self {
        case .payload_0:
            return "(Satellite)"
        case .payload_1:
            return "(Cubesat)"
        case .payload_2:
            return "(Supplies)"
        case .payload_3:
            return "(Crew)"
        case .payload_4:
            return "(Probe)"
        case .payload_5:
            return "(Rover)"
        case .payload_6:
            return "(Lander)"
        case .payload_7:
            return "(Habitat)"
        case .payload_8:
            return "(Telescope)"
        case .payload_9:
            return "(Other)"
        case .notAvailable:
            return ""
        }
    }
}
