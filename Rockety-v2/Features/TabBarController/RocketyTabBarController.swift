//
//  RocketyTabBarController.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 02.11.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation
import UIKit

class RocketyTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // UI
        tabBar.tintColor = UIColor(named: "TabBar-Icon")
        // Font
        UITabBarItem.appearance().setTitleTextAttributes([.font: UIFont(name: "Barlow-SemiBold", size: 12.0)!], for: .normal)
        // Shadow
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowRadius = 5
        tabBar.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        tabBar.layer.shadowOpacity = 0.15
    }
    
}
