//
//  LaunchLibrary.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 06.08.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation
import Moya

public enum LaunchLibrary {
    case launches(offset: Int?, queryString: String?)
    case agencies(offset: Int?, queryString: String?)
    case pads(offset: Int?)
}

extension LaunchLibrary: TargetType {
    
    public var baseURL: URL {
        return URL(string: "https://ll.thespacedevs.com/2.0.0")!
    }
    
    public var path: String {
        switch self {
        case .launches:
            return "/launch/upcoming/"
        case .agencies:
            return "/agencies/"
        case .pads:
            return "/pad/"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .launches, .agencies, .pads:
            return .get
        }
    }
    
    public var sampleData: Data {
        // FIXME: To be implemented.
        return Data()
    }
    
    public var task: Task {
        switch self {
        case let .launches(offset, queryString), let .agencies(offset, queryString):
            return .requestParameters(parameters: ["mode": "detailed", "limit": "50", "offset": offset ?? 0, "search": queryString ?? ""], encoding: URLEncoding.default)
        case let .pads(offset):
            return .requestParameters(parameters: ["limit": "100", "offset": offset ?? 0], encoding: URLEncoding.default)
        }
    }
    
    public var headers: [String : String]? {
        return nil
    }
    
    public var validationType: ValidationType {
        return .successCodes
    }
}
