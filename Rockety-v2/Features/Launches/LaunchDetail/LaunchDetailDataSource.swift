//
//  LaunchDetailDataSource.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 24.10.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation
import UIKit

protocol LaunchDetailDataSourceDelegate: class {
    func openLink(url: URL)
    func showNoLink()
}

class LaunchDetailDataSource: BaseDataSource {
    // - Properties
    weak var delegate: LaunchDetailDataSourceDelegate?
    
    func load(withLaunch launch: Launch) {
        clearValues()
        
        // Header
        appendRow(value: launch, cellClass: LaunchHeaderTableViewCell.self, toSection: 0)
        
        // Rocket + Missions
        appendRow(value: launch, cellClass: LaunchRocketTableViewCell.self, toSection: 0)
        
        // Flight
        appendRow(value: launch, cellClass: LaunchFlightTableViewCell.self, toSection: 0)
        
        // Links
        let onPressTap: (() -> Void) = { [weak self] in
            if let link = launch.infoURLs?.first?.url {
                self?.delegate?.openLink(url: link)
            } else {
                self?.delegate?.showNoLink()
            }
        }
        
        let onYoutubeTap: (() -> Void) = { [weak self] in
            if let link = launch.vidURLs?.first?.url {
                self?.delegate?.openLink(url: link)
            } else {
                self?.delegate?.showNoLink()
            }
        }
        
        appendRow(value: LaunchLinksTableViewCell.Value(onPressTap: onPressTap, onYoutubeTap: onYoutubeTap), cellClass: LaunchLinksTableViewCell.self, toSection: 0)
    }
}
