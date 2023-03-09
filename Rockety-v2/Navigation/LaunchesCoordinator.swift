//
//  LaunchesCoordinator.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 24.10.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import EventKit
import Foundation
import RxSwift
import SafariServices
import UIKit

class LaunchesCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController!
    
    func start() {
        let launchesVC: LaunchesViewController = LaunchesViewController.instantiate()
        launchesVC.navigationDelegate = self
        navigationController = BaseNavigationController(rootViewController: launchesVC)
        navigationController.tabBarItem = UITabBarItem(title: "Launches", image: UIImage(named: "tabbar_rocket"), selectedImage: nil)
    }
    
    func dismiss() {
        // Nope
    }
}

// MARK: - LaunchesNavigationDelegate

extension LaunchesCoordinator: LaunchesNavigationDelegate {
    func showDetail(launch: Launch) {
        let viewModel = LaunchDetailViewModel(launch: launch)
        let viewController = LaunchDetailViewController.instantiate(withViewModel: viewModel)
        viewController.navigationDelegate = self
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
    }
}

// MARK: - LaunchDetailNavigationDelegate

extension LaunchesCoordinator: LaunchDetailNavigationDelegate {
    func pop() {
        navigationController.popViewController(animated: true)
    }
    
    func openLink(url: URL) {
        let viewController = SFSafariViewController(url: url)
        viewController.preferredBarTintColor = UIColor(named: "Background")
        viewController.preferredControlTintColor = UIColor.white
        navigationController.present(viewController, animated: true, completion: nil)
    }
    
    func showNoLink(sender: LaunchDetailViewController) {
        let alertController = CFAlertViewController(title: "Oops!", message: "No link is available for the moment.", textAlignment: .center, preferredStyle: .alert, didDismissAlertHandler: nil)
        let defaultAction = CFAlertAction(title: "OK", style: .Default, alignment: .center, backgroundColor: UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1), textColor: UIColor.white, handler: nil)
        alertController.addAction(defaultAction)
        sender.present(alertController, animated: true, completion: nil)
    }
    
    func showCalendarAuthorizationDenied(sender: LaunchDetailViewController) {
        let alertController = CFAlertViewController(title: "Oops!", message: "You didn't authorize us to access your calendar. Do you want to give us access in the Settings?", textAlignment: .center, preferredStyle: .alert, didDismissAlertHandler: nil)
        let settingsAction = CFAlertAction(title: "Open Settings", style: .Default, alignment: .center, backgroundColor: UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1), textColor: .white) { (action) in
            let openSettingsURL = URL(string: UIApplication.openSettingsURLString)
            UIApplication.shared.open(openSettingsURL!, options: [:], completionHandler: nil)
        }
        let cancelAction = CFAlertAction(title: "Cancel", style: .Cancel, alignment: .center, backgroundColor: UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1), textColor: UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1), handler: nil)
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        sender.present(alertController, animated: true, completion: nil)
    }
    
    func showCalendarAuthorizationNotDetermined(sender: LaunchDetailViewController, onAccept: @escaping (() -> Void)) {
        let alertController = CFAlertViewController(title: "Oops!", message: "You didn't authorize us to access your calendar. Do you want to give us access to add the event in your calendar?", textAlignment: .center, preferredStyle: .alert, didDismissAlertHandler: nil)
        let authorizeAction = CFAlertAction(title: "Authorize", style: .Default, alignment: .center, backgroundColor: UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1), textColor: .white) { (action) in
            let eventStore = EKEventStore()
            eventStore.requestAccess(to: .event) { (accessGranted, error) in
                if accessGranted {
                    onAccept()
                }
            }
        }
        let cancelAction = CFAlertAction(title: "Cancel", style: .Cancel, alignment: .center, backgroundColor: UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1), textColor: UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1), handler: nil)
        alertController.addAction(authorizeAction)
        alertController.addAction(cancelAction)
        sender.present(alertController, animated: true, completion: nil)
    }
    
    func showEventAdded(sender: LaunchDetailViewController) {
        let alertController = CFAlertViewController(title: "Event added!", message: "This launch was added to your calendar.", textAlignment: .center, preferredStyle: .alert, didDismissAlertHandler: nil)
        let okAction = CFAlertAction(title: "OK", style: .Default, alignment: .center, backgroundColor: UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1), textColor: .white, handler: nil)
        alertController.addAction(okAction)
        sender.present(alertController, animated: true, completion: nil)
    }
    
    func showEventAddedError(sender: LaunchDetailViewController) {
        let alertController = CFAlertViewController(title: "Oops!", message: "Houston, we've have had a problem here. The event couldn't have been saved. Please check that you authorized Rockety to access your calendar.", textAlignment: .center, preferredStyle: .alert, didDismissAlertHandler: nil)
        let okAction = CFAlertAction(title: "OK", style: .Default, alignment: .center, backgroundColor: UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1), textColor: .white, handler: nil)
        alertController.addAction(okAction)
        sender.present(alertController, animated: true, completion: nil)
    }
}

// MARK: - DeepLink

extension LaunchesCoordinator: DeepLinkNavigator {
    func navigate(to deepLink: DeepLink) {
        switch deepLink {
        case let .launch(id):
            guard let launchesVC = navigationController.viewControllers.first as? LaunchesViewController else { return }
            launchesVC.viewModel.inputs.openLaunch(id: id)
        }
    }
}
