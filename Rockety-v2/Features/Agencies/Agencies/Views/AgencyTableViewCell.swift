//
//  AgencyTableViewCell.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 25.10.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation
import IsoCountryCodes
import UIKit

class AgencyTableViewCell: UITableViewCell {
    // - Outlets
    @IBOutlet private var agencyTitleLabel: UILabel!
    @IBOutlet private var agencyCountryLabel: UILabel!
}

// MARK: - ValueCell

extension AgencyTableViewCell: ValueCell {
    func configure(with value: Agency) {
        agencyTitleLabel.text = value.name
        agencyCountryLabel.text = IsoCountryCodes.find(key: value.countryCode!)?.flag
    }
}
