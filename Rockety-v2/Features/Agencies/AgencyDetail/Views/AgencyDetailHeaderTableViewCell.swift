//
//  AgencyDetailHeaderTableViewCell.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 25.10.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation
import UIKit

class AgencyDetailHeaderTableViewCell: UITableViewCell {
    // - Outlets
    @IBOutlet private var agencyTitleLabel: UILabel!
    @IBOutlet private var agencyLogoImageView: UIImageView!
    @IBOutlet private var agencyDescriptionLabel: UILabel!
}

// MARK: - Configuration

extension AgencyDetailHeaderTableViewCell: ValueCell {
    func configure(with value: Agency) {
        agencyTitleLabel.text = value.name
        agencyLogoImageView.image = value.image()
        agencyDescriptionLabel.text = value.description
    }
}
