//
//  Fetcher.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 03.11.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation

struct Fetcher {
    // At the moment, we always use PROD server
    public var launchUrl = "https://ll.thespacedevs.com/2.0.0/launch/upcoming/?limit=10"
    
    func fetch<D: Decodable>(decodeTo model: D.Type, completion: @escaping (D?) -> ()) {
        let url = URL(string: launchUrl)!
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { data, _, error in
            if error != nil {
                return
            }
            if let data = data {
                if let decodedData = decode(data: data, decodeTo: model) {
                    completion(decodedData)
                }
            }
        }
        task.resume()
    }
    
    func decode<D: Decodable>(data: Data, decodeTo model: D.Type) -> D? {
        let decoder = RocketyJSONDecoder()
        do {
            let decodedData = try decoder.decode(model, from: data)
            return decodedData
        } catch {
            print(error)
            return nil
        }
    }
}

