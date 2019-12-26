//
//  FlightTableViewCell.swift
//  Rockety
//
//  Created by Antoine Bellanger on 21.05.18.
//  Copyright © 2018 Antoine Bellanger. All rights reserved.
//

import UIKit

class MissionTableViewCell: UITableViewCell {
    
    @IBOutlet var missionNameLabel: UILabel!
    @IBOutlet var missionOperatorLabel: UILabel!
    @IBOutlet var missionRocketLabel: UILabel!
    @IBOutlet var missionLaunchSiteLabel: UILabel!
    @IBOutlet var missionDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
