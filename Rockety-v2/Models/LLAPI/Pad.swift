//
//  Pad.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 06.08.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation
import MapKit

class Pad: Decodable {
    let id: Int?
    let url: String?
    let agencyId: Int?
    let name: String?
    let infoUrl: String?
    let wikiUrl: String?
    let mapUrl: String?
    let latitude: String
    let longitude: String
    let location: Location
    let mapImage: String?
    let totalLaunchCount: Int?
}

extension Pad: Equatable {
    static func == (lhs: Pad, rhs: Pad) -> Bool {
        return lhs.id == rhs.id
    }
}

class PadAnnotation: NSObject, MKAnnotation {
    let name: String
    let coordinate: CLLocationCoordinate2D
    let totalLaunchCount: Int?
    
    init(pad: Pad) {
        self.name = pad.name ?? "Unnamed pad"
        self.coordinate = CLLocationCoordinate2D(latitude: Double(pad.latitude)!, longitude: Double(pad.longitude)!)
        self.totalLaunchCount = pad.totalLaunchCount
        super.init()
    }
    
    var title: String? {
        return name
    }
    
    var subtitle: String? {
        if let totalLaunchCount = totalLaunchCount, totalLaunchCount > 0 {
            if totalLaunchCount == 1 {
                return "\(totalLaunchCount) rocket has been launched from here!"
            } else {
                return "\(totalLaunchCount) rockets have been launched from here!"
            }
        } else {
            return "This pad has not been used for a launch yet!"
        }
    }
}
