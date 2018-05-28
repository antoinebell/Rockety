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
                return "https://launchlibrary.net/1.4/launch/next/25"
//                return "https://launchlibrary.net/1.4/launch?next=25&fields=name,lsp,net,location,rocket&sort=asc"
            case .agency(let agencyId):
                return "https://launchlibrary.net/1.4/agency/\(agencyId)"
            case .launchpad(let launchpadId):
                return "https://launchlibrary.net/1.4/pad/\(launchpadId)"
            }
        }
    }
    
    enum Images {
        
        case falcon1
        case falcon9
        case falconheavy
        
        case longmarch2a
        case longmarch2c
        case longmarch2d
        case longmarch2e
        case longmarch2f
        case longmarch3
        case longmarch3a
        case longmarch3b
        case longmarch3c
        case longmarch4a
        case longmarch4b
        case longmarch4c
        
        case hii
        case hiia
        case hiib
        case hii202
        case hii204
        
        case none
        
        func url() -> String {
            
            let baseURL = "http://api.antoinebellanger.ch/rockety/models"
            
            switch self {
            case .falcon1:
                return baseURL + "/Falcon-1.png"
            case .falcon9:
                return baseURL + "/Falcon-9.png"
            case .falconheavy:
                return baseURL + "/Falcon-Heavy.png"
            case .longmarch2a:
                return baseURL + "/LongMarch-2A.png"
            case .longmarch2c:
                return baseURL + "/LongMarch-2C.png"
            case .longmarch2d:
                return baseURL + "/LongMarch-2D.png"
            case .longmarch2e:
                return baseURL + "/LongMarch-2E.png"
            case .longmarch2f:
                return baseURL + "/LongMarch-2F.png"
            case .longmarch3:
                return baseURL + "/LongMarch-3.png"
            case .longmarch3a:
                return baseURL + "/LongMarch-3A.png"
            case .longmarch3b:
                return baseURL + "/LongMarch-3B.png"
            case .longmarch3c:
                return baseURL + "/LongMarch-3C.png"
            case .longmarch4a:
                return baseURL + "/LongMarch-4A.png"
            case .longmarch4b:
                return baseURL + "/LongMarch-4B.png"
            case .longmarch4c:
                return baseURL + "/LongMarch-4C.png"
            case .hii:
                return baseURL + "/H-II.png"
            case .hiia:
                return baseURL + "/H-IIA.png"
            case .hiib:
                return baseURL + "/H-IIB.png"
            case .hii202:
                return baseURL + "/H-II-202.png"
            case .hii204:
                return baseURL + "/H-II-204.png"
            case .none:
                return baseURL
            }
        }
    }
    
}
