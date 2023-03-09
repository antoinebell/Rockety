//
//  BaseViewModel.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 06.08.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation
import RxSwift

/// ActivityIndicating will provide information about the current loading status.
protocol ActivityIndicating {
    /// Emits the loading activity status.
    var isLoading: ActivityIndicator { get }
}

/// The BaseViewModel will be reused as a base for all our view models and implements the ActivityIndicating protocol.
class BaseViewModel {
    let disposeBag = DisposeBag()

    lazy var isLoading = ActivityIndicator()
}
