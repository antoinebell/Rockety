//
//  AgencyTableViewCell.swift
//  Rockety
//
//  Created by Antoine Bellanger on 05.06.18.
//  Copyright © 2018 Antoine Bellanger. All rights reserved.
//

import UIKit

class AgencyTableViewCell: UITableViewCell {
    
    @IBOutlet var agencyNameLabel: UILabel!
    @IBOutlet var agencyCountryLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
