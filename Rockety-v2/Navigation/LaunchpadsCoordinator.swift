//
//  LaunchpadsCoordinator.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 03.11.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation
import UIKit

class LaunchpadsCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController!
    
    func start() {
        let launchpadsVC: LaunchpadsViewController = LaunchpadsViewController.instantiate()
        navigationController = BaseNavigationController(rootViewController: launchpadsVC)
        navigationController.tabBarItem = UITabBarItem(title: "Launchpads", image: UIImage(named: "tabbar_maps"), selectedImage: nil)
    }
    
    func dismiss() {
        // Nope...
    }
}
