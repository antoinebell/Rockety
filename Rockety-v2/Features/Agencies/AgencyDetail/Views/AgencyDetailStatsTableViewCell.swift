//
//  AgencyDetailStatsTableViewCell.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 25.10.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation
import UIKit

class AgencyDetailStatsTableViewCell: UITableViewCell {
    // - Outlets
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var stat1TitleLabel: UILabel!
    @IBOutlet private var stat1ValueLabel: UILabel!
    @IBOutlet private var stat2TitleLabel: UILabel!
    @IBOutlet private var stat2ValueLabel: UILabel!
    @IBOutlet private var stat3TitleLabel: UILabel!
    @IBOutlet private var stat3ValueLabel: UILabel!
}

// MARK: - Configuration

extension AgencyDetailStatsTableViewCell: ValueCell {
    struct Value {
        enum StatType {
            case launches
            case landings
        }
        let agency: Agency
        let statType: StatType
    }
    func configure(with value: Value) {
        switch value.statType {
        case .launches:
            titleLabel.text = "Launches"
            stat1TitleLabel.text = "SUCCESSFUL"
            stat1ValueLabel.text = "\(value.agency.successfulLaunches ?? 0)"
            stat2TitleLabel.text = "ALL"
            stat2ValueLabel.text = "\(value.agency.totalLaunchCount ?? 0)"
            stat3TitleLabel.text = "PLANNED"
            stat3ValueLabel.text = "\(value.agency.pendingLaunches ?? 0)"
        case .landings:
            titleLabel.text = "Landings"
            stat1TitleLabel.text = "SUCCESSFUL"
            stat1ValueLabel.text = "\(value.agency.successfulLandings ?? 0)"
            stat2TitleLabel.text = "FAILED"
            stat2ValueLabel.text = "\(value.agency.failedLandings ?? 0)"
            stat3TitleLabel.text = "ATTEMPTED"
            stat3ValueLabel.text = "\(value.agency.attemptedLandings ?? 0)"
        }
    }
}
