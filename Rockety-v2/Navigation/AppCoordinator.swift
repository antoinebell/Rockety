//
//  AppCoordinator.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 24.10.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

class AppCoordinator: Coordinator {
    
    let window: UIWindow
    let rootTabBarController: RocketyTabBarController
    var childCoordinators: [Coordinator] = []
    let disposeBag = DisposeBag()

    init(window: UIWindow) {
        self.window = window
        rootTabBarController = RocketyTabBarController()
        
    }

    func start() {
        let launchesCoordinator = LaunchesCoordinator()
        storeChildCoordinator(launchesCoordinator)
        
        let agenciesCoordinator = AgenciesCoordinator()
        storeChildCoordinator(agenciesCoordinator)
        
        let launchpadsCoordinator = LaunchpadsCoordinator()
        storeChildCoordinator(launchpadsCoordinator)
        
        launchesCoordinator.start()
        agenciesCoordinator.start()
        launchpadsCoordinator.start()
        
        rootTabBarController.viewControllers = [
            launchesCoordinator.navigationController,
            agenciesCoordinator.navigationController,
            launchpadsCoordinator.navigationController
        ]
        
        window.rootViewController = rootTabBarController
        window.makeKeyAndVisible()
    }
    
    func dismiss() {
        // Nope
    }
}

// MARK: - DeepLink

extension AppCoordinator: DeepLinkNavigator {
    func navigate(to deepLink: DeepLink) {
        switch deepLink {
        case .launch:
            rootTabBarController.selectedIndex = 0
            if let launchesCoordinator = topChildCoordinator(ofType: LaunchesCoordinator.self) {
                launchesCoordinator.navigate(to: deepLink)
            }
        }
    }
}
