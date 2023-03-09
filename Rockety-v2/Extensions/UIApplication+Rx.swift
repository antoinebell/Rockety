//
//  UIApplication+Rx.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 04.11.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

fileprivate var applicationStateSubjectContext: UInt8 = 0

extension Reactive where Base: UIApplication {
    
    /**
     Observable sequence of the application's state.
     This gives you an observable sequence of all possible application states.
     
     The idea is from here: https://github.com/e-sites/RxSwiftly/blob/master/Source/UIKit/UIApplication/UIApplication%2Brx.swift
     
     - warning: Setting up a Rx KVO on "applicationState" will not work, whereas `applicationState` is not KVO compliant. That's why we set use a NotificationCenter
     
     - returns: Observable sequence of `UIApplicationState`s
     */
    public var applicationState: Observable<UIApplication.State> {
        
        if let observableApplicationState = objc_getAssociatedObject(self, &applicationStateSubjectContext) as? Observable<UIApplication.State> {
            return observableApplicationState
        } else {
            let observables = [
                UIApplication.didBecomeActiveNotification,
                UIApplication.didEnterBackgroundNotification,
                UIApplication.willEnterForegroundNotification,
                UIApplication.didFinishLaunchingNotification,
                UIApplication.willResignActiveNotification,
                UIApplication.willTerminateNotification
                ].compactMap {
                    NotificationCenter.default.rx.notification($0)
            }
            
            let observableApplicationState = Observable<Foundation.Notification>.merge(observables)
                .map { _ in UIApplication.shared.applicationState }
                .distinctUntilChanged()
            
            objc_setAssociatedObject(self, &applicationStateSubjectContext, observableApplicationState, .OBJC_ASSOCIATION_RETAIN)
            return observableApplicationState
        }
    }
}
