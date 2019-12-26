//
//  BulletinDataSource.swift
//  Rockety
//
//  Created by Antoine Bellanger on 26.05.18.
//  Copyright © 2018 Antoine Bellanger. All rights reserved.
//

import UIKit
import BLTNBoard
import UserNotifications
import EventKit

enum BulletinDataSource {
    
    //MARK: Pages
    
    static func makeIntroPage() -> FeedbackPageBulletinItem {
        let page = FeedbackPageBulletinItem(title: "Welcome to Rockety !")
        page.image = #imageLiteral(resourceName: "space-shuttle-small")
        
        page.descriptionText = "Check out when the next rocket launches."
        page.actionButtonTitle = "Ignite"
        page.isDismissable = false
        
        page.appearance.actionButtonColor = UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1)
        
        page.actionHandler = { item in
            item.manager?.push(item: self.makeNotificationsPage())
        }
        
        return page
    }
    
    static func makeNotificationsPage() -> FeedbackPageBulletinItem {
        let page = FeedbackPageBulletinItem(title: "Push Notifications")
        page.image = #imageLiteral(resourceName: "NotificationPrompt")
        
        page.descriptionText = "Receive push notifications before liftoff."
        page.actionButtonTitle = "Subscribe"
        page.alternativeButtonTitle = "Not now"
        
        page.isDismissable = false
        
        page.appearance.actionButtonColor = UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1)
        page.appearance.alternativeButtonTitleColor = UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1)
        
        page.actionHandler = { item in
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge,. sound], completionHandler: { (granted, error) in
                if granted {
                    userDidSubscribeNotifications = true
                    
                    // Register for remote notifications
                    UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                        print("Notification Settings: \(settings)")
                        
                        guard settings.authorizationStatus == .authorized else { return }
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    }
                } else {
                    userDidSubscribeNotifications = false
                }
            })
            NotificationCenter.default.post(name: .SetupDidCompleteNotification, object: item)
            item.manager?.push(item: self.makeCompletionPage())
        }
        
        page.alternativeHandler = { item in
            NotificationCenter.default.post(name: .SetupDidCompleteNotification, object: item)
            item.manager?.push(item: self.makeCompletionPage())
        }
        
        page.next = makeCompletionPage()
        
        return page
    }
    
    static func makeCompletionPage() -> BLTNPageItem {
        
        let page = BLTNPageItem(title: "Main Engine Start")
        page.image = #imageLiteral(resourceName: "IntroCompletion")
        
        page.descriptionText = "You're ready to go. T-3, 2, 1..."
        page.actionButtonTitle = "Liftoff !"
        
        page.isDismissable = false
        
        page.appearance.actionButtonColor = UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1)

        page.dismissalHandler = { item in
            item.manager?.dismissBulletin(animated: true)
            NotificationCenter.default.post(name: .SetupDidComplete, object: item)
        }
        
        page.actionHandler = { item in
            NotificationCenter.default.post(name: .SetupDidComplete, object: item)
            item.manager?.dismissBulletin(animated: true)
        }
        
        return page
    }
    
 
    //MARK: UserDefaults
    
    /// Whether user completed setup.
    static var userDidCompleteSetup: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "UserDidCompleteSetup")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "UserDidCompleteSetup")
        }
    }
    
    static var userDidCompleteSetupCalendar: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "UserDidCompleteSetupCalendar")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "UserDidCompleteSetupCalendar")
        }
    }
    
    static var userDidSubscribeNotifications: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "UserDidSubscribeNotifications")
        }
        set {
            print("Settings notification value:", newValue)
            UserDefaults.standard.set(newValue, forKey: "UserDidSubscribeNotifications")
        }
    }
    
}

// MARK: - Notifications

extension Notification.Name {
    
    /**
     * The setup did complete.
     *
     * The user info dictionary is empty.
     */
    
    static let SetupDidComplete = Notification.Name("SetupDidCompleteNotification")
    
    static let SetupDidCompleteCalendar = Notification.Name("SetupDidCompleteCalendarNotification")
    
    static let SetupDidCompleteNotification = Notification.Name("SetupDidCompleteNotification")
    
}
