//
//  MissionDetailTableViewCell.swift
//  Rockety
//
//  Created by Antoine Bellanger on 22.05.18.
//  Copyright © 2018 Antoine Bellanger. All rights reserved.
//

import UIKit
import MapKit

class MissionDetailTitleTableViewCell: UITableViewCell {
    
    @IBOutlet var missionNumberLabel: UILabel!
    @IBOutlet var missionTitleLabel: UILabel!
    @IBOutlet var missionPatchImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

class MissionDetailRocketTableViewCell: UITableViewCell {
    
    @IBOutlet var rocketNameLabel: UILabel!
    @IBOutlet var rocketOwnerLabel: UILabel!
    @IBOutlet var rocketDescriptionLabel: UILabel!
    @IBOutlet var rocketImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

class MissionDetailStage1TableViewCell: UITableViewCell {
    
    @IBOutlet var rocketCoreSerialLabel: UILabel!
    @IBOutlet var rocketCoreReusedLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

class MissionDetailStage1DTableViewCell: UITableViewCell {
    
    @IBOutlet var rocketCoreSerialLabel: UILabel!
    @IBOutlet var rocketCoreReusedLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

class MissionDetailStage2TableViewCell: UITableViewCell {
    
    @IBOutlet var rocketCoreIdLabel: UILabel!
    @IBOutlet var rocketCoreCustomersLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

class MissionDetailStage2DTableViewCell: UITableViewCell {
    
    @IBOutlet var rocketCoreIdLabel: UILabel!
    @IBOutlet var rocketCoreCustomersLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

class MissionDetailLaunchTableViewCell: UITableViewCell {
    
    @IBOutlet var launchSiteNameLabel: UILabel!
    @IBOutlet var launchSiteNameLongLabel: UILabel!
    @IBOutlet var launchSiteMapView: MKMapView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

class MissionDetailPressTableViewCell: UITableViewCell {
    
    @IBOutlet var pressButton: UIButton!
    @IBOutlet var youtubeButton: UIButton!
    @IBOutlet var redditButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
