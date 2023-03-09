//
//  LaunchRocketTableViewCell.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 24.10.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation
import IsoCountryCodes
import UIKit

class LaunchRocketTableViewCell: UITableViewCell {
    
    // - Outlets
    @IBOutlet private var rocketImageView: UIImageView!
    @IBOutlet private var rocketNameLabel: UILabel!
    @IBOutlet private var rocketLSPLabel: UILabel!
    @IBOutlet private var rocketDescriptionLabel: UILabel!
    @IBOutlet private var launcherLabel: UILabel!
    @IBOutlet private var stagesStackView: UIStackView!
    @IBOutlet private var missionNameLabel: UILabel!
    @IBOutlet private var missionTypeLabel: UILabel!
    @IBOutlet private var missionDescriptionLabel: UILabel!
}

// MARK: - Configuration

extension LaunchRocketTableViewCell: ValueCell {
    func configure(with value: Launch) {
        // Image
        DispatchQueue.main.async {
            self.rocketImageView.contentMode = .scaleAspectFit
            self.rocketImageView.image = value.rocket?.configuration?.launchLibraryId?.image()
        }
        
        // Rocket
        rocketNameLabel.text = value.rocket?.configuration?.fullName
        rocketLSPLabel.text = "\(value.rocket?.configuration?.manufacturer?.name ?? "Unknown manufacturer")  \(IsoCountryCodes.find(key: (value.rocket?.configuration?.manufacturer?.countryCode)!)!.flag!)"
        rocketDescriptionLabel.text = value.rocket?.configuration?.launchLibraryId?.description()
        
        // Launcher
        if let launcherStages = value.rocket?.launcherStage {
            if launcherStages.count > 0 {
                for launcherStage in launcherStages {
                    let launcherView = LauncherView()
                    launcherView.configure(launcher: launcherStage.launcher!)
                    stagesStackView.addArrangedSubview(launcherView)
                }
            } else {
                let label = UILabel()
                label.text = "No launcher information for this flight."
                label.textColor = UIColor(named: "Text")
                label.font = UIFont(name: "Barlow-Light", size: 15.0)
                label.numberOfLines = 1
                stagesStackView.addArrangedSubview(label)
            }
        }
        
        // Mission
        missionNameLabel.text = value.mission?.name ?? "Unnamed mission"
        missionTypeLabel.text = value.mission?.type ?? "Undisclosed"
        missionDescriptionLabel.text = value.mission?.description ?? "The mission details have not been disclosed publicly."
    }
}
