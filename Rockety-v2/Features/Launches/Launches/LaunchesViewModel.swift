//
//  LaunchesViewModel.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 06.08.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol LaunchesViewModelInputs {
    /// Called when we should load the data
    func loadData()

    /// Called when the table view scroll reached to bottom.
    func didScrollToBottom()

    /// Called when we need to filter the launches
    func filterLaunches(query: String)

    /// Called when a row was selected
    func rowSelected(indexPath: IndexPath)
    
    /// Called from a deeplink
    func openLaunch(id: String)
}

protocol LaunchesViewModelOutputs: ActivityIndicating {
    /// Emits the retrieved list of launches.
    var launches: Driver<Launches?> { get }

    /// Signals when a row was selected
    var rowSelected: Driver<Launch?> { get }
}

protocol LaunchesViewModelType {
    var inputs: LaunchesViewModelInputs { get }
    var outputs: LaunchesViewModelOutputs { get }
}

final class LaunchesViewModel: BaseViewModel, LaunchesViewModelType, LaunchesViewModelInputs, LaunchesViewModelOutputs {
    var inputs: LaunchesViewModelInputs { return self }
    var outputs: LaunchesViewModelOutputs { return self }

    // MARK: - Inputs

    func loadData() {
        loadDataRelay.accept(())
    }

    func didScrollToBottom() {
        guard let launches = launchesRelay.value else {
            return
        }

        downloadLaunches(offset: offsetRelay.value + launches.results.count, queryString: queryStringRelay.value)
            .map { $0.prependLaunches(launches.results) }
            .bind(to: launchesRelay)
            .disposed(by: disposeBag)
    }

    func filterLaunches(query: String) {
        queryStringRelay.accept(query)
    }

    func rowSelected(indexPath: IndexPath) {
        guard let launches = launchesRelay.value?.results else { return }
        selectedLaunchRelay.accept(launches[indexPath.row])
    }
    
    func openLaunch(id: String) {
        openLaunchIdRelay.accept(id)
    }

    // MARK: - Outputs

    var launches: Driver<Launches?> {
        return launchesRelay.asDriver()
    }

    var rowSelected: Driver<Launch?> {
        return selectedLaunchRelay.asDriver()
    }

    // MARK: - Private

    // - Properties
    private let lllaunchesAPIService: LLLaunchesAPIService

    // - Private relays
    private let offsetRelay = BehaviorRelay<Int>(value: 0)
    private let queryStringRelay = BehaviorRelay<String>(value: "")

    // - Input relays
    private let loadDataRelay = PublishRelay<Void>()
    private let openLaunchIdRelay = BehaviorRelay<String?>(value: nil)

    // - Output relays
    private let launchesRelay = BehaviorRelay<Launches?>(value: nil)
    private let selectedLaunchRelay = BehaviorRelay<Launch?>(value: nil)

    // MARK: - Init

    init(lllaunchesAPIService: LLLaunchesAPIService = LLLaunchesAPIService()) {
        self.lllaunchesAPIService = lllaunchesAPIService

        super.init()

        Observable.combineLatest(loadDataRelay.asObservable(), queryStringRelay.asObservable())
            .map { [unowned self] _ in (self.offsetRelay.value, self.queryStringRelay.value) }
            .flatMapLatest(wcall(self, LaunchesViewModel.downloadLaunches))
            .bind(to: launchesRelay)
            .disposed(by: disposeBag)
        
        launchesRelay
            .asObservable()
            .unwrap()
            .bind { [unowned self] launches in
                guard let launchId = openLaunchIdRelay.value else { return }
                guard let launch = launches.results.first(where: { $0.id == launchId }) else { return }
                selectedLaunchRelay.accept(launch)
                openLaunchIdRelay.accept(nil)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Helpers

private extension LaunchesViewModel {
    func downloadLaunches(offset: Int?, queryString: String?) -> Observable<Launches> {
        return lllaunchesAPIService
            .requestLaunches(offset: offset, queryString: queryString)
            .filterElementsTracking(activity: isLoading)
    }
}
