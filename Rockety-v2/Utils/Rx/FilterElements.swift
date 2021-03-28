//
//  FilterElements.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 06.08.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation
import RxSwift

extension ObservableType {

    /// Returns only the stream elements.
    func filterElements() -> Observable<Element> {
        return materialize()
            .elements()
    }

    /// Returns only the stream elements, feeding also the activity indicator stream.
    func filterElementsTracking(activity: ActivityIndicator) -> Observable<Element> {
        return trackActivity(activity)
            .filterElements()
    }
}

extension PrimitiveSequence where Trait == SingleTrait {

    /// Returns only the stream elements.
    func filterElements() -> Observable<Element> {
        return asObservable()
            .filterElements()
    }

    /// Returns only the stream elements, feeding also the activity indicator stream.
    func filterElementsTracking(activity: ActivityIndicator) -> Observable<Element> {
        return asObservable()
            .filterElementsTracking(activity: activity)
    }
}
