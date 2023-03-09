//
//  Agency.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 06.08.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation
import UIKit

class Agency: Decodable {
    let id: Int?
    let url: String?
    let name: String
    let type: String?
    let countryCode: String?
    let abbrev: String?
    let description: String?
    let administrator: String?
    let foundingYear: String?
    let launchers: String?
    let spacecraft: String?
    let totalLaunchCount: Int?
    let consecutiveSuccessfulLaunches: Int?
    let successfulLaunches: Int?
    let failedLaunches: Int?
    let pendingLaunches: Int?
    let consecutiveSuccessfulLandings: Int?
    let successfulLandings: Int?
    let failedLandings: Int?
    let attemptedLandings: Int?
    let infoUrl: String?
    let wikiUrl: String?
    let logoUrl: String?
    let imageUrl: String?
    let nationUrl: String?
    let launcherList: [AgencyLauncher]?
    
    func image() -> UIImage? {
        guard let logoUrl = URL(string: logoUrl ?? "") else { return nil }
        do {
            let data = try Data(contentsOf: logoUrl)
            return UIImage(data: data)
        } catch {
            return nil
        }
    }
}
