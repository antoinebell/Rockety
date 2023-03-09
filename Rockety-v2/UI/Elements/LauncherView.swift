//
//  LauncherView.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 25.10.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation
import UIKit

class LauncherView: UIView, NibOwnerLoadable {
    // - Outlets
    @IBOutlet var rocketCoreSerialLabel: UILabel!
    @IBOutlet var rocketCoreReusedLabel: UILabel!
    
    // - Initializers
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    func commonInit() {
        loadNibContent()
    }
}

// MARK: - Configuration

extension LauncherView {
    func configure(launcher: Launcher) {
        rocketCoreSerialLabel.text = launcher.serialNumber
        
        rocketCoreReusedLabel.layer.borderColor = UIColor.white.cgColor
        rocketCoreReusedLabel.layer.borderWidth = 0.5
        rocketCoreReusedLabel.layer.cornerRadius = 10
        
        if let flights = launcher.flights {
            if flights > 1 {
                rocketCoreReusedLabel.text = "Reused"
                rocketCoreReusedLabel.isHidden = false
            } else {
                rocketCoreReusedLabel.text = "New"
                rocketCoreReusedLabel.isHidden = false
            }
        } else {
            rocketCoreReusedLabel.isHidden = true
        }
    }
}
