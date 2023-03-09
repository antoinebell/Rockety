//
//  LaunchFlightTableViewCell.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 25.10.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation
import UIKit

class LaunchFlightTableViewCell: UITableViewCell {
    
    // - Outlets
    @IBOutlet private var launchSiteTitleLabel: UILabel!
    @IBOutlet private var launchSiteValueLabel: UILabel!
    @IBOutlet private var launchOrbitLabel: UILabel!
    @IBOutlet private var launchLandingTitleLabel: UILabel!
    @IBOutlet private var launchLandingValueLabel: UILabel!
}

// MARK: - Configuration

extension LaunchFlightTableViewCell: ValueCell {
    func configure(with value: Launch) {
        // Launch Site
        launchSiteTitleLabel.text = value.pad?.name ?? "Unknown pad"
        launchSiteValueLabel.text = value.pad?.location.name ?? "Unknown location"
        
        // Mission
        let orbitType = value.mission?.orbit?.abbrev
        var orbitTypeString = ""
        if let orbitType = orbitType {
            orbitTypeString = "(\(orbitType))"
        }
        launchOrbitLabel.text = "\(value.mission?.orbit?.name ?? "Unknown payload orbit") \(orbitTypeString)"
        
        // Landing
        let platformType = value.rocket?.launcherStage?.first?.landing?.type?.name
        var platformTypeString = ""
        if let platformType = platformType {
            platformTypeString = "(\(platformType))"
        }
        launchLandingTitleLabel.text = "\(value.rocket?.launcherStage?.first?.landing?.location?.name ?? "This rocket is not coming back!") \(platformTypeString)"
        launchLandingValueLabel.text = value.rocket?.launcherStage?.first?.landing?.location?.description
    }
}
