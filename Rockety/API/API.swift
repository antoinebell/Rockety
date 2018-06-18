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
        case agencies
        case agencyMissions(agencyId: String)
        case launchpad(launchpadId: Int)
        case pads

        func url() -> String {
            
            let baseURL = "https://launchlibrary.net/1.4.1"
            
            switch self {
            case .nextLaunches:
                return baseURL + "/launch/next/75"
//                return "https://launchlibrary.net/1.4.1/launch/864"
            case .agency(let agencyId):
                return baseURL + "/agency/\(agencyId)"
            case .agencies:
                return baseURL + "/lsp/next/100"
            case .agencyMissions(let agencyId):
                return baseURL + "/launch?lsp=\(agencyId)&limit=200&mode=verbose"
            case .launchpad(let launchpadId):
                return baseURL + "/pad/\(launchpadId)"
            case .pads:
                return baseURL + "/pad?limit=200"
            }
        }
    }
    
    enum Images {
        
        //SpaceX
        case falcon1
        case falcon9
        case falconheavy
        
        //LongMarch
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
        
        //IndianSpaceResearchOrganisation
        case gslvmkii
        case gslvmkiii
        case pslv
        
        //Arianespace
        case ariane5
        case ariane6
        case soyuz
        case vega
        case vegac
        
        //Eurockot
        case rokot
        
        //Nooooo
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
            case .gslvmkii:
                return baseURL + "/GSLV-Mk-II.png"
            case .gslvmkiii:
                return baseURL + "/GSLV-Mk-III.png"
            case .pslv:
                return baseURL + "/PSLV.png"
            case .ariane5:
                return baseURL + "/Ariane-5.png"
            case .ariane6:
                return baseURL + "/Ariane-6.png"
            case .soyuz:
                return baseURL + "/Soyuz.png"
            case .vega:
                return baseURL + "/Vega.png"
            case .vegac:
                return baseURL + "/Vega-C.png"
            case .rokot:
                return baseURL
            case .none:
                return baseURL
            }
        }
    }
    
    enum Descriptions {
        
        //SpaceX
        case falcon1
        case falcon9
        case falconheavy
        
        //LongMarch
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
        
        //IndianSpaceResearchOrganisation
        case gslvmkii
        case gslvmkiii
        case pslv
        
        //Arianespace
        case ariane5
        case ariane6
        case soyuz
        case vega
        case vegac
        
        //Eurockot
        case rokot
        
        //Nooooo
        case none
        
        func url() -> String {
            
            let baseURL = "http://api.antoinebellanger.ch/rockety/texts"
            
            switch self {
            case .falcon1:
                return baseURL + "/Falcon-1.txt"
            case .falcon9:
                return baseURL + "/Falcon-9.txt"
            case .falconheavy:
                return baseURL + "/Falcon-Heavy.txt"
            case .longmarch2a:
                return baseURL + "/LongMarch.txt"
            case .longmarch2c:
                return baseURL + "/LongMarch.txt"
            case .longmarch2d:
                return baseURL + "/LongMarch.txt"
            case .longmarch2e:
                return baseURL + "/LongMarch.txt"
            case .longmarch2f:
                return baseURL + "/LongMarch.txt"
            case .longmarch3:
                return baseURL + "/LongMarch.txt"
            case .longmarch3a:
                return baseURL + "/LongMarch.txt"
            case .longmarch3b:
                return baseURL + "/LongMarch.txt"
            case .longmarch3c:
                return baseURL + "/LongMarch.txt"
            case .longmarch4a:
                return baseURL + "/LongMarch.txt"
            case .longmarch4b:
                return baseURL + "/LongMarch.txt"
            case .longmarch4c:
                return baseURL + "/LongMarch.txt"
            case .gslvmkii:
                return baseURL + "/GSLV-Mk-II.txt"
            case .gslvmkiii:
                return baseURL + "/GSLV-Mk-III.txt"
            case .pslv:
                return baseURL + "/PSLV.txt"
            case .ariane5:
                return baseURL + "/Ariane-5.txt"
            case .ariane6:
                return baseURL + "/Ariane-6.txt"
            case .soyuz:
                return baseURL + "/Soyuz.txt"
            case .vega:
                return baseURL + "/Vega.txt"
            case .vegac:
                return baseURL + "/Vega-C.txt"
            case .rokot:
                return baseURL + "/Rokot.txt"
            case .none:
                return baseURL + "/default.txt"
            }
        }
    }
    
}
