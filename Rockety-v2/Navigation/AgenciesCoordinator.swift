//
//  AgenciesCoordinator.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 25.10.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation
import UIKit

class AgenciesCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController!
    
    func start() {
        let agenciesVC: AgenciesViewController = AgenciesViewController.instantiate()
        agenciesVC.navigationDelegate = self
        navigationController = BaseNavigationController(rootViewController: agenciesVC)
        navigationController.tabBarItem = UITabBarItem(title: "Agencies", image: UIImage(named: "tabbar_agency"), selectedImage: nil)
    }
    
    func dismiss() {
        // Nope...
    }
}

// MARK: - AgenciesNavigationDelegate

extension AgenciesCoordinator: AgenciesNavigationDelegate {
    func showDetail(agency: Agency) {
        let agencyDetailVC: AgencyDetailViewController = AgencyDetailViewController.instantiate(withViewModel: AgencyDetailViewModel(agency: agency))
        agencyDetailVC.navigationDelegate = self
        agencyDetailVC.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(agencyDetailVC, animated: true)
    }
}

// MARK: - AgencyDetailNavigationDelegate

extension AgenciesCoordinator: AgencyDetailNavigationDelegate {
    func pop() {
        navigationController.popViewController(animated: true)
    }
}
