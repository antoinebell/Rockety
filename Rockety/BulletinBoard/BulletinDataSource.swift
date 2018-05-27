//
//  BulletinDataSource.swift
//  Rockety
//
//  Created by Antoine Bellanger on 26.05.18.
//  Copyright © 2018 Antoine Bellanger. All rights reserved.
//

import UIKit
import BulletinBoard
import UserNotifications
import EventKit

enum BulletinDataSource {
    
    //MARK: Pages
    
    static func makeIntroPage() -> FeedbackPageBulletinItem {
        let page = FeedbackPageBulletinItem(title: "Welcome to Rockety !")
        page.image = #imageLiteral(resourceName: "spaceshuttle")
        
        page.descriptionText = "Check out when the next rocket launches."
        page.actionButtonTitle = "Ignite"
        page.isDismissable = false
        
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
        
        page.actionHandler = { item in
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge,. sound], completionHandler: { (granted, error) in
                print("UserNotifications granted ?", granted)
            })
            item.manager?.push(item: self.makeCompletionPage())
        }
        
        page.alternativeHandler = { item in
            item.manager?.push(item: self.makeCompletionPage())
        }
        
        page.nextItem = makeCompletionPage()
        
        return page
    }
    
    static func makeCompletionPage() -> PageBulletinItem {
        
        let page = PageBulletinItem(title: "Main Engine Start")
        page.image = #imageLiteral(resourceName: "IntroCompletion")
        //        page.appearance.actionButtonColor = #colorLiteral(red: 0.2980392157, green: 0.8509803922, blue: 0.3921568627, alpha: 1)
//        page.appearance.imageViewTintColor = #colorLiteral(red: 0.2980392157, green: 0.8509803922, blue: 0.3921568627, alpha: 1)
//        page.appearance.actionButtonTitleColor = .white
        
        page.descriptionText = "You're ready to go. T-3, 2, 1..."
        page.actionButtonTitle = "Liftoff !"
        
        page.isDismissable = false
        
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
    
    static func makeCalendarPage() -> FeedbackPageBulletinItem {
        let page = FeedbackPageBulletinItem(title: "Calendar")
        page.image = #imageLiteral(resourceName: "NotificationPrompt")
        
        page.descriptionText = "Add launches to calendar."
        page.actionButtonTitle = "Prepare for Liftoff"
        page.alternativeButtonTitle = "Not now"
        
        page.isDismissable = false
        
        page.actionHandler = { item in
            let eventStore = EKEventStore()
            eventStore.requestAccess(to: .event, completion: { (accessGranted, error) in
                
                DispatchQueue.main.async {
                    
                    if accessGranted {
                        MissionsDetailViewController().insertEvent()
                    }
                    
                    item.manager?.dismissBulletin(animated: true)
                }
            })
        }
        
        page.alternativeHandler = { item in
            item.manager?.dismissBulletin(animated: true)
        }
        
        return page
    }
 
    //MARK: User Notifications
    
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
    
}
