//
//  RocketId.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 25.10.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation
import UIKit

enum RocketId: String, Decodable {
    case rocket1 // Falcon 9 v1.1
    case rocket2 // Atlas V 541
    case rocket3 // Soyuz 2.1b
    case rocket9 // Ariane 5 ES
    case rocket10 // Atlas V 531
    case rocket14 // PSLV
    case rocket15 // Rokot
    case rocket18 // Vega
    case rocket22 // Long March 3B
    case rocket25 // Long March 2F
    case rocket26 // Atlas V 401
    case rocket27 // Ariane 5 ECA
    case rocket32 // Atlas V 501
    case rocket35 // Soyuz U
    case rocket36 // Soyuz-FG
    case rocket37 // Atlas V 551
    case rocket38 // PSLV-XL
    case rocket49 // Soyuz 2.1a
    case rocket50 // Rokot/Briz-KM
    case rocket51 // Long March 3C/YZ-1
    case rocket52 // Soyuz STB/Fregat
    case rocket55 // Atlas V 421
    case rocket58 // Falcon Heavy
    case rocket60 // GSLV Mk II
    case rocket61 // Soyuz 2.1v/Volga
    case rocket65 // Soyuz 2.1b/Fregat
    case rocket66 // Soyuz 2.1a/Volga
    case rocket68 // PSLV-CA
    case rocket69 // Long March 3B/E
    case rocket70 // Long March 4C
    case rocket71 // Long March 11
    case rocket72 // Long March 6
    case rocket73 // Long March 2D
    case rocket75 // Long March 2C
    case rocket76 // Soyuz STA/Fregat
    case rocket80 // Falcon 9 Full Thrust (Block 3)
    case rocket81 // Long March 3C/E
    case rocket83 // Soyuz 2.1a/Fregat-M
    case rocket85 // GSLV Mk III
    case rocket88 // Long March 3A
    case rocket89 // Long March 3B/YZ-1
    case rocket90 // Falcon 9 v1.0
    case rocket92 // Long March 2F
    case rocket96 // Soyuz STB/Fregat-MT
    case rocket97 // Long March 3C
    case rocket102 // Soyuz-FG/Fregat
    case rocket103 // Long March 2C/SMA
    case rocket106 // Atlas V 411
    case rocket111 // Long March 2F/G
    case rocket116 // Long March 4B
    case rocket118 // Atlas V N22
    case rocket119 // Atlas V 431
    case rocket121 // Falcon 9 v1.1
    case rocket130 // Long March 7
    case rocket133 // Soyuz-U2
    case rocket134 // Soyuz
    case rocket146 // Long March 5 / YZ-2
    case rocket147 // Soyuz Fregat
    case rocket148 // Electron
    case rocket153 // Soyuz 2.1b/Fregat-m
    case rocket155 // Long March 7 / YZ-1A
    case rocket156 // Ariane 5 G
    case rocket160 // Falcon 1
    case rocket164 // Ariane 62
    case rocket165 // Ariane 64
    case rocket166 // Atlas V 552
    case rocket167 // Long March ?
    case rocket170 // Long March 1
    case rocket172 // Soyuz 2.1v
    case rocket173 // LauncherOne
    case rocket174 // Ariane 5 GS
    case rocket175 // Ariane 5 G +
    case rocket187 // Falcon 9 Block 4
    case rocket188 // Falcon 9 Block 5
    case rocket192 // Long March 2C / YZ-15
    case rocket213 // Long March 2D / YZ-3
    case rocket215 // PSLV-DL
    case rocket218 // PSLV-QL
    case rocket219 // Atlas V
    case rocket235 // Soyuz 2.1a/Fregat
    case rocket240 // Long March 5B
    case rocket243 // Astra Rocket 3.0
    case rocket244 // Atlas V 511
    case rocket245 // Atlas V 521
    case rocket246 // Ariane 5 ECA+
    case rocket999 // None
    
    init(id: Int) {
        self = RocketId(rawValue: "rocket\(id)") ?? .rocket999
    }
    
    func description() -> String {
        do {
            return try String(contentsOf: descriptionURL()).replacingOccurrences(of: "\\n", with: "\n")
        } catch {
            return "No information on that rocket, it must be brand new!"
        }
    }
    
    func image() -> UIImage? {
        do {
            let data = try Data(contentsOf: imageURL())
            return UIImage(data: data)
        } catch {
            return nil
        }
    }
    
    private func descriptionURL() -> URL {
        return URL(string: "https://rockety-backend.herokuapp.com/description?rocketId=\(rawValue)")!
    }
    
    func imageURL() -> URL {
        return URL(string: "https://rockety-backend.herokuapp.com/image?rocketId=\(rawValue)")!
    }
}

extension RocketId {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(Int.self)
        self.init(id: value)
    }
}
