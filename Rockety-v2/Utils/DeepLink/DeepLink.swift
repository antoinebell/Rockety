//
//  DeepLink.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 04.11.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation

enum DeepLink {
    // Launch
    case launch(id: String)
}

// MARK: - Initialization

extension DeepLink {
    /// Initialize a DeepLink from URL
    init?(from url: URL) {
        guard url.scheme == "rockety" else { return nil }
        guard url.host == "v1" else { return nil }

        let path = url.pathComponents
        var iterator = path.makeIterator()

        // skip the first element, it is the leading "/"
        _ = iterator.next()

        // pattern matching for creating the deep link from the url path
        switch (iterator.next(), iterator.next()) {
        case let ("launch", id):
            guard let id = id else { return nil }
            self = .launch(id: id)

        default:
            return nil
        }
    }
}
