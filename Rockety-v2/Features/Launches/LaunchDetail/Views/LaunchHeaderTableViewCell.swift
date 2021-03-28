//
//  LaunchHeaderTableViewCell.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 24.10.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation
import UIKit

class LaunchHeaderTableViewCell: UITableViewCell {
    
    // - Outlets
    @IBOutlet private var missionTitleLabel: UILabel!
    @IBOutlet private var missionStatusLabel: UILabel!
    @IBOutlet private var missionStartWindowLabel: UILabel!
    @IBOutlet private var missionProbabilityView: UIView!
    @IBOutlet private var missionProbabilityProgressView: StatusProgressView!
}

// MARK: - Configuration

extension LaunchHeaderTableViewCell: ValueCell {
    func configure(with value: Launch) {
        missionTitleLabel.text = "\(value.launchTitle ?? value.name ?? "Unnamed mission")"
        missionStatusLabel.attributedText = setupStatus(launch: value)
        missionStartWindowLabel.text = value.windowStart?.localizedDescription(dateStyle: .long, timeStyle: .long)
        if let probability = value.probability {
            if probability != -1 && (value.status?.id == .go || value.status?.id == .tbd || value.status?.id == .hold) {
            missionProbabilityView.isHidden = false
            missionProbabilityProgressView.setProgress(Float(10), animated: false)
            } else {
                missionProbabilityView.isHidden = true
            }
        } else {
            missionProbabilityView.isHidden = true
        }
    }
}

// MARK: - Private helpers

extension LaunchHeaderTableViewCell {
    private func setupStatus(launch: Launch) -> NSMutableAttributedString {
        let status = NSMutableAttributedString()
        
        let statusTitle = NSAttributedString(string: "Status:", attributes: [.font: UIFont(name: "Barlow-Light", size: 17.0)!])
        status.append(statusTitle)
        
        let statusValue = NSAttributedString(string: " \(launch.status?.id.value ?? "")" , attributes: [.font: UIFont(name: "Barlow-Medium", size: 17.0)!])
        status.append(statusValue)
        
        if let holdReason = launch.holdreason {
            status.append(NSAttributedString(string: "\n\(holdReason)", attributes:  [.font: UIFont(name: "Barlow-Light", size: 17.0)!]))
        } else if let failReason = launch.failreason {
            status.append(NSAttributedString(string: "\n\(failReason)", attributes:  [.font: UIFont(name: "Barlow-Light", size: 17.0)!]))
        }
        return status
    }
}
