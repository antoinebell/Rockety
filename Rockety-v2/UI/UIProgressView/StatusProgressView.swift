//
//  StatusProgressView.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 24.10.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation
import UIKit

class StatusProgressView: UIProgressView {
    
    override var progress: Float {
        didSet {
            setupColors()
        }
    }
    
    private func setupColors() {
        if progress < 0.4 {
            progressTintColor = UIColor(named: "Red")
        } else if progress > 0.4, progress < 0.7 {
            progressTintColor = UIColor(named: "Yellow")
        } else {
            progressTintColor = UIColor(named: "Green")
        }
    }
}
