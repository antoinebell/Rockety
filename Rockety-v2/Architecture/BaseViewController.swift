//
//  BaseViewController.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 06.08.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

/// The BaseViewController will be reused as a base for all our view controllers.
class BaseViewController: UIViewController, StoryboardInstantiable {
    let disposeBag = DisposeBag()
}

// MARK: - Activity tracking

extension BaseViewController {
    func bindActivity(_ activityIndicating: ActivityIndicating, activityIndicator: UIActivityIndicatorView) {
        activityIndicator.hidesWhenStopped = true
        activityIndicating.isLoading
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
    }
}
