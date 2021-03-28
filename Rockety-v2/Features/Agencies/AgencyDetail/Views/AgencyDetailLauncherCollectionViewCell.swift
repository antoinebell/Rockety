//
//  AgencyDetailLauncherCollectionViewCell.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 25.10.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation
import UIKit

class AgencyDetailLauncherCollectionViewCell: UICollectionViewCell, CellIdentifiable {
    // - Outlets
    @IBOutlet private var cardView: UIView!
    @IBOutlet private var launcherTitleLabel: UILabel!
    @IBOutlet private var launcherImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
}

// MARK: - Private methods

extension AgencyDetailLauncherCollectionViewCell {
    private func setupUI() {
        cardView.layer.masksToBounds = true
        cardView.layer.borderColor = UIColor.lightGray.cgColor
        cardView.layer.borderWidth = 0.5
    }
}

// MARK: - Configuration

extension AgencyDetailLauncherCollectionViewCell: ValueCell {
    func configure(with value: AgencyLauncher) {
        launcherTitleLabel.text = value.fullName
        launcherImageView.image = value.launchLibraryId?.image()
    }
}
