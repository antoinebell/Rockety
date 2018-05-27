//
//  API.swift
//  Rockety
//
//  Created by Antoine Bellanger on 21.05.18.
//  Copyright © 2018 Antoine Bellanger. All rights reserved.
//

import Foundation

struct API {
    
    enum SpaceX {
        case allRockets
        case rocket(rocketId: String)
        
        case allLaunchpads
        case launchpad(launchpadId: String)
        
        case pastLaunch
        case nextLaunch
        case pastLaunches
        case nextLaunches
        case allLaunches
        
        func url() -> String {
            switch self {
            case .allRockets:
                return "https://api.spacexdata.com/v2/rockets"
            case .rocket(let rocketId):
                return "https://api.spacexdata.com/v2/rockets/\(rocketId)"
            case .allLaunchpads:
                return "https://api.spacexdata.com/v2/launchpads"
            case .launchpad(let launchpadId):
                return "https://api.spacexdata.com/v2/launchpads/\(launchpadId)"
            case .pastLaunch:
                return "https://api.spacexdata.com/v2/launches/latest"
            case .nextLaunch:
                return "https://api.spacexdata.com/v2/launches/next"
            case .pastLaunches:
                return "https://api.spacexdata.com/v2/launches"
            case .nextLaunches:
                return "https://api.spacexdata.com/v2/launches/upcoming"
            case .allLaunches:
                return "https://api.spacexdata.com/v2/launches/all"
            }
        }
        
    }
    
    enum All {
        case nextLaunches
        case agency(agencyId: String)
        case launchpad(launchpadId: Int)
        
        func url() -> String {
            switch self {
            case .nextLaunches:
                return "https://launchlibrary.net/1.4/launch?next=25&fields=name,lsp,net,location,rocket&sort=asc"
            case .agency(let agencyId):
                return "https://launchlibrary.net/1.4/agency/\(agencyId)"
            case .launchpad(let launchpadId):
                return "https://launchlibrary.net/1.4/pad/\(launchpadId)"
            }
        }
    }
    
}
