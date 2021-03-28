//
//  AgenciesViewModel.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 25.10.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol AgenciesViewModelInputs {
    /// Called when we should load the data
    func loadData()
    
    /// Called when the table view scroll reached to bottom.
    func didScrollToBottom()
    
    /// Called when we need to filter the launches
    func filterAgencies(query: String)
    
    /// Called when a row was selected
    func rowSelected(indexPath: IndexPath)
}

protocol AgenciesViewModelOutputs: ActivityIndicating {
    /// Emits the retrieved list of agencies.
    var agencies: Driver<Agencies?> { get }
    
    /// Signals when a row was selected
    var rowSelected: Driver<Agency?> { get }
}

protocol AgenciesViewModelType {
    var inputs: AgenciesViewModelInputs { get }
    var outputs: AgenciesViewModelOutputs { get }
}

final class AgenciesViewModel: BaseViewModel, AgenciesViewModelType, AgenciesViewModelInputs, AgenciesViewModelOutputs {
    
    var inputs: AgenciesViewModelInputs { return self }
    var outputs: AgenciesViewModelOutputs { return self }
    
    // MARK: - Inputs
    
    func loadData() {
        loadDataRelay.accept(())
    }
    
    func didScrollToBottom() {
        guard let agencies = agenciesRelay.value else {
            return
        }
        
        downloadAgencies(offset: offsetRelay.value + agencies.results.count, queryString: "")
            .map { $0.prependAgencies(agencies.results) }
            .bind(to: agenciesRelay)
            .disposed(by: disposeBag)
    }
    
    func filterAgencies(query: String) {
        queryStringRelay.accept(query)
    }
    
    func rowSelected(indexPath: IndexPath) {
        guard let agencies = agenciesRelay.value?.results else { return }
        selectedAgencyRelay.accept(agencies[indexPath.row])
    }
    
    // MARK: - Outputs
    
    var agencies: Driver<Agencies?> {
        return agenciesRelay.asDriver()
    }
    
    var rowSelected: Driver<Agency?> {
        return selectedAgencyRelay.asDriver()
    }
    
    // MARK: - Private
    
    // - Properties
    private let lllaunchesAPIService: LLLaunchesAPIService
    
    // - Private relays
    private let offsetRelay = BehaviorRelay<Int>(value: 0)
    private let queryStringRelay = BehaviorRelay<String>(value: "")
    
    // - Input relays
    private let loadDataRelay = PublishRelay<Void>()
    
    // - Output relays
    private let agenciesRelay = BehaviorRelay<Agencies?>(value: nil)
    private let selectedAgencyRelay = BehaviorRelay<Agency?>(value: nil)
    
    // MARK: - Init
    init(lllaunchesAPIService: LLLaunchesAPIService = LLLaunchesAPIService()) {
        self.lllaunchesAPIService = lllaunchesAPIService

        super.init()
        
        Observable.combineLatest(loadDataRelay.asObservable(), queryStringRelay.asObservable())
            .map { [unowned self] _ in (self.offsetRelay.value, self.queryStringRelay.value) }
            .flatMapLatest(wcall(self, AgenciesViewModel.downloadAgencies))
            .bind(to: agenciesRelay)
            .disposed(by: disposeBag)
    }
}

// MARK: - Helpers

private extension AgenciesViewModel {
    func downloadAgencies(offset: Int?, queryString: String?) -> Observable<Agencies> {
        return lllaunchesAPIService
            .requestAgencies(offset: offset, queryString: queryString)
            .filterElementsTracking(activity: isLoading)
    }
}
