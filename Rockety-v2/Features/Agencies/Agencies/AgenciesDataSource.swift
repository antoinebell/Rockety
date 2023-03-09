//
//  AgenciesDataSource.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 25.10.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation

class AgenciesDataSource: BaseDataSource {
    func load(agencies: [Agency]) {
        clearValues()
        
        appendSection(values: agencies, cellClass: AgencyTableViewCell.self)
    }
}
