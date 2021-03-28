//
//  Link.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 25.10.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation

struct Link: Decodable {
    let priority: Int?
    let title: String?
    let description: String?
    let featureImage: URL?
    let url: URL?
}
