//
//  LaunchpadsViewModel.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 03.11.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol LaunchpadsViewModelInputs {
    /// Called when viewWillAppear
    func viewWillAppear()
}

protocol LaunchpadsViewModelOutputs: ActivityIndicating {
    /// Emits the launchpads
    var launchpads: Driver<Launchpads?> { get }
}

protocol LaunchpadsViewModelType {
    var inputs: LaunchpadsViewModelInputs { get }
    var outputs: LaunchpadsViewModelOutputs { get }
}

final class LaunchpadsViewModel: BaseViewModel, LaunchpadsViewModelType, LaunchpadsViewModelInputs, LaunchpadsViewModelOutputs {
    
    var inputs: LaunchpadsViewModelInputs { return self }
    var outputs: LaunchpadsViewModelOutputs { return self }
    
    // MARK: - Inputs
    func viewWillAppear() {
        viewWillAppearRelay.accept(())
    }
    
    // MARK: - Outputs
    var launchpads: Driver<Launchpads?> {
        return launchpadsRelay.asDriver()
    }
    
    // MARK: - Private
    
    // - Properties
    private let lllaunchesAPIService: LLLaunchesAPIService
    
    // - Private relays
    private let offsetRelay = BehaviorRelay<Int>(value: 0)
    
    // - Input relays
    private let viewWillAppearRelay = PublishRelay<Void>()
    
    // - Output relays
    private let launchpadsRelay = BehaviorRelay<Launchpads?>(value: nil)
    
    // MARK: - Init
    init(lllaunchesAPIService: LLLaunchesAPIService = LLLaunchesAPIService()) {
        self.lllaunchesAPIService = lllaunchesAPIService

        super.init()
        
        viewWillAppearRelay
            .asObservable()
            .map { [unowned self] _ in self.offsetRelay.value }
            .flatMapLatest(downloadLaunchpads(offset:))
            .bind(to: launchpadsRelay)
            .disposed(by: disposeBag)
        
        launchpadsRelay
            .asObservable()
            .unwrap()
            .takeWhile { $0.next != nil }
            .mapAt(\.results)
            .map { [unowned self] results in
                self.offsetRelay.value + results.count
            }
            .bind(to: offsetRelay)
            .disposed(by: disposeBag)
        
        offsetRelay
            .asObservable()
            .skip(1) // First request is done by viewWillAppear
            .flatMapLatest(downloadLaunchpads(offset:))
            .map { [unowned self] launchpads -> Launchpads? in
                guard let previousLaunchpads = self.launchpadsRelay.value else { return nil }
                return launchpads.prependLaunchpads(previousLaunchpads.results)
            }
            .bind(to: launchpadsRelay)
            .disposed(by: disposeBag)
    }
}

// MARK: - Helpers

private extension LaunchpadsViewModel {
    func downloadLaunchpads(offset: Int?) -> Observable<Launchpads> {
        return lllaunchesAPIService
            .requestPads(offset: offset)
            .filterElementsTracking(activity: isLoading)
    }
}
