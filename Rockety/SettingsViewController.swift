//
//  SettingsViewController.swift
//  Rockety
//
//  Created by Antoine Bellanger on 27.05.18.
//  Copyright © 2018 Antoine Bellanger. All rights reserved.
//

import UIKit
import AIFlatSwitch
import UserNotifications

class SettingsViewController: UIViewController {
    
    @IBOutlet var spaceXSwitch: AIFlatSwitch!
    @IBOutlet var elseSwitch: AIFlatSwitch!
    
    //MARK: UserDefaults
    
    /// Whether user completed setup.
    static var spaceXNotifications: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "SpaceXNotifications")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "SpaceXNotifications")
        }
    }
    
    static var elseNotifications: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "ElseNotifications")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "ElseNotifications")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        spaceXSwitch.setSelected(SettingsViewController.spaceXNotifications, animated: false)
        elseSwitch.setSelected(SettingsViewController.elseNotifications, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: IBAction
    
    @IBAction func spaceXNotifications(_ sender: AIFlatSwitch) {
        if sender.isSelected {
            SettingsViewController.spaceXNotifications = true
        } else {
            SettingsViewController.spaceXNotifications = false
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
    }
    
    @IBAction func elseNotifications(_ sender: AIFlatSwitch) {
        if sender.isSelected {
            SettingsViewController.elseNotifications = true
        } else {
            SettingsViewController.elseNotifications = false
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
