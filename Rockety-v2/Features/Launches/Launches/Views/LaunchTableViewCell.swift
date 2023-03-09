//
//  LaunchTableViewCell.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 06.08.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation
import UIKit

class LaunchTableViewCell: UITableViewCell {
    
    // - Outlets
    @IBOutlet private var missionNameLabel: UILabel!
    @IBOutlet private var missionOperatorLabel: UILabel!
    @IBOutlet private var missionRocketPadLabel: UILabel!
    @IBOutlet private var missionDateLabel: UILabel!
}

// MARK: - ValueCell

extension LaunchTableViewCell: ValueCell {
    func configure(with value: Launch) {
        missionNameLabel.text = "\(value.launchTitle ?? value.name ?? "Unnamed mission")"
        missionOperatorLabel.text = value.launchServiceProvider?.name ?? "Undisclosed launch service provider"
        missionRocketPadLabel.text = "\(value.rocket?.configuration?.fullName ?? "Unknown rocket") | \(value.pad?.name ?? "Unknown pad")"
        missionDateLabel.text = value.net?.localizedDescription(dateStyle: .long, timeStyle: .long)
    }
}
