//
//  AgencyDetailViewModel.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 25.10.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol AgencyDetailViewModelInputs {}

protocol AgencyDetailViewModelOutputs: ActivityIndicating {
    /// Returns the agency
    var agency: Agency { get }
}

protocol AgencyDetailViewModelType {
    var inputs: AgencyDetailViewModelInputs { get }
    var outputs: AgencyDetailViewModelOutputs { get }
}

final class AgencyDetailViewModel: BaseViewModel, AgencyDetailViewModelType, AgencyDetailViewModelInputs, AgencyDetailViewModelOutputs {
    
    var inputs: AgencyDetailViewModelInputs { return self }
    var outputs: AgencyDetailViewModelOutputs { return self }
    
    // MARK: - Inputs
    
    // MARK: - Outputs
    
    var agency: Agency
    
    // MARK: - Private
    
    // - Properties
    
    // - Input relays
    
    // - Output relays
    
    // MARK: - Init
    init(agency: Agency) {
        self.agency = agency
        
        super.init()
    }
}
