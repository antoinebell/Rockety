//
//  LaunchesDataSource.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 06.08.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation
import UIKit

class LaunchesDataSource: BaseDataSource {
    
    func load(launches: [Launch]) {
        clearValues()
        
        set(values: launches, cellClass: LaunchTableViewCell.self, inSection: 0)
    }
}
