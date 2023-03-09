//
//  LLLaunchesAPIService.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 06.08.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import RxSwiftExt

protocol LLLaunchesAPIServiceType {
    func requestLaunches(offset: Int?, queryString: String?) -> Single<Launches>
    func requestAgencies(offset: Int?, queryString: String?) -> Single<Agencies>
    func requestPads(offset: Int?) -> Single<Launchpads>
}

struct LLLaunchesAPIService: LLLaunchesAPIServiceType {
    let apiRequestService: APIRequestService
    init(apiRequestService: APIRequestService = APIRequestService.shared) {
        self.apiRequestService = apiRequestService
    }
}

// MARK: - Request Launches

extension LLLaunchesAPIService {
    /// This LaunchLibrary API call will request all the upcoming launches.
    ///
    /// - Parameters:
    ///     - offset: The current offset (nil = 0)
    ///     - queryString: A search string if inputted
    /// - Returns: A single instance of Launches.
    func requestLaunches(offset: Int?, queryString: String?) -> Single<Launches> {
        return apiRequestService.request(.launches(offset: offset, queryString: queryString), for: Launches.self)
    }
}

// MARK: - Request Agencies

extension LLLaunchesAPIService {
    /// This LaunchLibrary API call will request all the agencies.
    ///
    /// - Parameters:
    ///     - offset: The current offset (nil = 0)
    ///     - queryString: A search string if inputted
    /// - Returns: A single instance of Launches.
    func requestAgencies(offset: Int?, queryString: String?) -> Single<Agencies> {
        return apiRequestService.request(.agencies(offset: offset, queryString: queryString), for: Agencies.self)
    }
}

// MARK: - Request Pads

extension LLLaunchesAPIService {
    /// This LaunchLibrary API call will request launchpads.
    ///
    /// - Parameters:
    ///     - offset: The current offset (nil = 0)
    /// - Returns: A single instance of Launches.
    func requestPads(offset: Int?) -> Single<Launchpads> {
        return apiRequestService.request(.pads(offset: offset), for: Launchpads.self)
    }
}
