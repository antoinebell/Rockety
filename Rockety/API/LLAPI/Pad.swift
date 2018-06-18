//
//  Pad.swift
//  Rockety
//
//  Created by Antoine Bellanger on 26.05.18.
//  Copyright © 2018 Antoine Bellanger. All rights reserved.
//

import Foundation
import MapKit

struct PadResult: Codable {
    
    let total: Int!
    let offset: Int!
    let count: Int!
    
    struct Pad: Codable  {
        let id: Int!
        let name: String!
        var padType: Int!
        let latitude: String!
        let longitude: String!
    }

    let pads: [Pad]
}

class Pad: NSObject, MKAnnotation {
    let title: String?
    let padType: Int!
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, padType: Int, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.padType = padType
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        if padType == 0 {
            return "Launch Pad"
        } else {
            return "Landing Pad"
        }
    }
}
