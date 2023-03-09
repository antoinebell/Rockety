//
//  APIRequestService.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 06.08.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation
import Moya
import RxMoya
import RxSwift

struct APIRequestService {
    let apiProvider: MoyaProvider<LaunchLibrary>
    let jsonDecoder: JSONDecoder
    
    static let shared = APIRequestService(provider: MoyaProvider<LaunchLibrary>())

    init(provider: MoyaProvider<LaunchLibrary>,
         decoder: JSONDecoder = RocketyJSONDecoder()) {
        apiProvider = provider
        jsonDecoder = decoder
    }
}

// MARK: - Networking Request

extension APIRequestService {
    /// Creates a request to a given target. Returns the deserialized response as a Single<Response> stream. All errors are logged, filtered out and mapped to APIErrors.
    /// This method will take care of ensuring we have the server keys if the request is encrypted
    /// and that we have a valid token if the request is authorized.
    func request<D: Decodable>(_ target: LaunchLibrary, for responseType: D.Type) -> Single<D> {
        return apiProvider.rx
            .request(target)
            .filterSuccessfulStatusCodes()
            .map(responseType, using: jsonDecoder)
            .catchError { (error) -> PrimitiveSequence<SingleTrait, D> in
                print("* Error Catched (raw): \(error.localizedDescription)")
                return Single.error(error)
            }
    }
}
