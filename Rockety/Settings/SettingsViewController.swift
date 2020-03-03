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
import CFAlertViewController
import SafariServices
import MobileCoreServices
import Crashlytics

class SettingsViewController: UIViewController {
    @IBOutlet var versionLabel: UILabel!
    @IBOutlet var rocketyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IAPHandler.shared.purchaseStatusBlock = { [weak self] (type) in
            guard let strongSelf = self else { return }
            if type == .purchased {
                DispatchQueue.main.async {
                    
                    let alertController = CFAlertViewController(title: "Thanks !", message: "Thank you for helping me !", textAlignment: .center, preferredStyle: .alert, didDismissAlertHandler: nil)
                    let okAction = CFAlertAction(title: "OK", style: .Default, alignment: .center, backgroundColor: UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1), textColor: UIColor.white, handler: nil)
                    alertController.addAction(okAction)
                    strongSelf.present(alertController, animated: true, completion: nil)
                    
                    Answers.logPurchase(withPrice: 2.00,
                                                 currency: "USD",
                                                 success: true,
                                                 itemName: "Support the Developer",
                                                 itemType: "Non-Consumable",
                                                 itemId: "supportdev.2",
                                                 customAttributes: [:])
                }
            }

        }
    
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.versionLabel.text = "v\(version)"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY"
        let year = dateFormatter.string(from: Date())
        rocketyLabel.text = "© \(year) Rockety. Made in 🇨🇭."
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBAction
    
    @IBAction func openSettings(_ button: UIButton) {
        if let URL = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(URL) {
                UIApplication.shared.open(URL, options: [:], completionHandler: nil)
            }
        }
    }
    
    @IBAction func support(_ button: UIButton) {
        IAPHandler.shared.purchaseMyProduct(index: 0)
    }
    
    @IBAction func licenses(_ button: UIButton) {
        let svc = SFSafariViewController(url: URL(string: "http://api.antoinebellanger.ch/rockety/Licenses.pdf")!)
        svc.preferredBarTintColor = UIColor(red: 17/255, green: 30/255, blue: 60/255, alpha: 1)
        svc.preferredControlTintColor = UIColor.white
        present(svc, animated: true, completion: nil)
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
