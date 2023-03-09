//
//  StatusCode.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 24.10.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation

enum StatusCode: Int, Decodable {
    case unknown = 0
    case go
    case tbd
    case success
    case failure
    case hold
    case inFlight
    case partialFailure
    
    var value: String {
        switch self {
        case .unknown:
            return "Unknown"
        case .go:
            return "Go"
        case .tbd:
            return "To be determined"
        case .success:
            return "Success"
        case .failure:
            return "Failure"
        case .hold:
            return "On hold"
        case .inFlight:
            return "In Flight"
        case .partialFailure:
            return "Partial Failure"
        }
    }
    
    var emoji: String {
        switch self {
        case .unknown:
            return ""
        case .go:
            return "🟢"
        case .tbd:
            return ""
        case .success:
            return "🟢"
        case .failure:
            return "🔴"
        case .hold:
            return "🟡"
        case .inFlight:
            return "🟢"
        case .partialFailure:
            return "🟠"
        }
    }
}
