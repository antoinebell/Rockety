//
//  DeepLinkNavigator.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 04.11.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation

/// Protocol implemented by entities that are responsible with navigation in the app
protocol DeepLinkNavigator: class {
    func navigate(to deepLink: DeepLink)
}
