//
//  DeepLinkManager.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 04.11.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

/// The facade entity that is responsibile with execution of a deep-link, commanding the navigation when certain conditions are met (the application state is active,  not in onboarding or manual recovery, etc.)
class DeepLinkManager {
    static let shared = DeepLinkManager()

    /// the instance responsable with navigation
    weak var navigator: DeepLinkNavigator?

    /// the observable application state (should be changed in unit tests with a mock implementation)
    var applicationState: Observable<UIApplication.State> = UIApplication.shared.rx.applicationState
    
    private var disposeBag: DisposeBag!
    private init() {}

    /// Asks the navigator to navigate to certain deep link.
    func navigate(to deepLink: DeepLink) {
        // clear the previous deeplink call...
        disposeBag = DisposeBag()

        // ...and install the current deep link call conditions & execution
        // using zip because we are waiting for the app to become active before handling the deep link
        Observable.zip(Observable.just(deepLink),
                       applicationState
                           .startWith(UIApplication.shared.applicationState)
                           .filter { $0 == .active })
            .map { deepLink, _ in deepLink }
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: navigator?.navigate)
            .disposed(by: disposeBag)
    }
}
