//
//  AppDelegate.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 06.08.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import RxSwift
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private var appCoordinator: AppCoordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if window == nil {
            let appWindow = UIWindow(frame: UIScreen.main.bounds)
            let applicationCoordinator = AppCoordinator(window: appWindow)
            window = appWindow
            appCoordinator = applicationCoordinator
        }

        // Set the DeepLink root navigator
        DeepLinkManager.shared.navigator = appCoordinator

        // Start
        appCoordinator?.start()

        return true
    }
}

// MARK: - Deep linking

extension AppDelegate {
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if let deepLink = DeepLink(from: url) {
            DeepLinkManager.shared.navigate(to: deepLink)
            return true
        }
        return false
    }
}
