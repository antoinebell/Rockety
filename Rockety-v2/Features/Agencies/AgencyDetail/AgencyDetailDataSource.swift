//
//  AgencyDetailDataSource.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 25.10.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation

class AgencyDetailDataSource: BaseDataSource {
    func load(agency: Agency) {
        clearValues()
        
        // Header
        appendRow(value: agency, cellClass: AgencyDetailHeaderTableViewCell.self, toSection: 0)
        
        // Launches
        appendRow(value: AgencyDetailStatsTableViewCell.Value(agency: agency, statType: .launches), cellClass: AgencyDetailStatsTableViewCell.self, toSection: 0)
        
        // Landings
        if agency.attemptedLandings ?? 0 > 1 {
            appendRow(value: AgencyDetailStatsTableViewCell.Value(agency: agency, statType: .landings), cellClass: AgencyDetailStatsTableViewCell.self, toSection: 0)
        }
        
        // Launchers
        if let launcherList = agency.launcherList {
            if launcherList.count > 0 {
                appendRow(value: launcherList, cellClass: AgencyDetailLaunchersTableViewCell.self, toSection: 0)
            }
        }
    }
}
