//
//  Launch.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 06.08.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation

struct Launch: Decodable {
    let slug: String
    let id: String?
    let url: String?
    let launchLibraryId: Int?
    let name: String?
    let status: Status?
    let net: Date?
    let windowEnd: Date?
    let windowStart: Date?
    let inhold: Bool?
    let tbdtime: Bool?
    let tbddate: Bool?
    let probability: Int?
    let holdreason: String?
    let failreason: String?
    let hashtag: String?
    let launchServiceProvider: Agency?
    let rocket: Rocket?
    let mission: Mission?
    let pad: Pad?
    let infoURLs: [Link]?
    let vidURLs: [Link]?
    let webcastLive: Bool?
    let image: String?
    let inforgraphic: String?
    
    var launchTitle: String? {
        guard let name = name else { return nil }
        let titleComponents = name.components(separatedBy: "|")
        guard titleComponents.count == 2 else { return nil }
        var title = titleComponents[1]
        title.removeFirst()
        return title
    }
    
    init(slug: String, id: String?, url: String?, launchLibraryId: Int?, name: String?, status: Status?, net: Date?, windowEnd: Date?, windowStart: Date?, inhold: Bool?, tbdtime: Bool?, tbddate: Bool?, probability: Int?, holdreason: String?, failreason: String?, hashtag: String?, launchServiceProvider: Agency?, rocket: Rocket?, mission: Mission?, pad: Pad?, infoURLs: [Link]?, vidURLs: [Link]?, webcastLive: Bool?, image: String?, inforgraphic: String?) {
        self.slug = slug
        self.id = id
        self.url = url
        self.launchLibraryId = launchLibraryId
        self.name = name
        self.status = status
        self.net = net
        self.windowEnd = windowEnd
        self.windowStart = windowStart
        self.inhold = inhold
        self.tbdtime = tbdtime
        self.tbddate = tbddate
        self.probability = probability
        self.holdreason = holdreason
        self.failreason = failreason
        self.hashtag = hashtag
        self.launchServiceProvider = launchServiceProvider
        self.rocket = rocket
        self.mission = mission
        self.pad = pad
        self.infoURLs = infoURLs
        self.vidURLs = vidURLs
        self.webcastLive = webcastLive
        self.image = image
        self.inforgraphic = inforgraphic
    }
}
