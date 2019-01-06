//
//  Mission.swift
//  Rockety
//
//  Created by Antoine Bellanger on 21.05.18.
//  Copyright © 2018 Antoine Bellanger. All rights reserved.
//

import Foundation

struct Mission: Codable {
    
    let flight_number: Int
    let mission_name: String
    let launch_date_utc: String
    let launch_date_local: String
    
    struct Rocket: Codable {
        let rocket_id: String
        let rocket_name: String
        let rocket_type: String
        let first_stage: FirstStage
        let second_stage: SecondStage
    }
    
    struct FirstStage: Codable {
        let cores: [Core]
    }
    
    struct Core: Codable {
        let core_serial: String?
        let flight: Int?
        let reused: Bool?
    }
    
    struct SecondStage: Codable {
        let payloads: [Payload]
    }
    
    struct Payload: Codable {
        let payload_id: String
        let reused: Bool?
        let customers: [String]
        let payload_type: String?
    }
    
    struct LaunchSite: Codable {
        let site_id: String
        let site_name: String
        let site_name_long: String
    }
    
    struct Links: Codable {
        let mission_patch: String?
        let presskit: String?
        let article_link: String?
        let video_link: String?
        let reddit_campaign: String?
    }
    
    let rocket: Rocket
    let launch_site: LaunchSite
    let links: Links
}
