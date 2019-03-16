//
//  Review.swift
//  Rockety
//
//  Created by Antoine Bellanger on 16.03.19.
//  Copyright © 2019 Antoine Bellanger. All rights reserved.
//

import Foundation
import StoreKit
import Crashlytics

class Review {
    
    let runIncrementSetting = "numberOfRuns"
    let minRunCount = 5
    
    func incrementAppRunCount() {
        let defaults = UserDefaults.standard
        let runs = getRunCounts() + 1
        defaults.set(runs, forKey: runIncrementSetting)
        defaults.synchronize()
    }
    
    func resetAppCount() {
        let defaults = UserDefaults.standard
        defaults.set(0, forKey: runIncrementSetting)
        defaults.synchronize()
    }
    
    func getRunCounts() -> Int {
        let defaults = UserDefaults.standard
        let savedRuns = defaults.value(forKey: runIncrementSetting)
        
        var runs = 0
        if (savedRuns != nil) {
            runs = savedRuns as! Int
        }
        
        return runs
    }
    
    func showReview() {
        let runs = getRunCounts()
        print("Show review")
        
        if (runs > minRunCount) {
            if #available(iOS 10.3, *) {
                print("Review requested")
                SKStoreReviewController.requestReview()
                resetAppCount()
            } else {
                // Fallback on earlier versions
            }
        } else {
            print("Count not high enough - \(runs)")
        }
    }
    
}

