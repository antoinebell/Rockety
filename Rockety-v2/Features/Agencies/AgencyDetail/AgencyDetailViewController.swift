//
//  AgencyDetailViewController.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 25.10.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

protocol AgencyDetailNavigationDelegate: class {
    func pop()
}

class AgencyDetailViewController: BaseViewController {
    // - Properties
    private var viewModel: AgencyDetailViewModelType!
    private let datasource = AgencyDetailDataSource()
    weak var navigationDelegate: AgencyDetailNavigationDelegate?
    
    // - Outlets
    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var tableView: UITableView!
    
    // - Initializer
    static func instantiate(withViewModel viewModel: AgencyDetailViewModelType) -> AgencyDetailViewController {
        let vc: AgencyDetailViewController = AgencyDetailViewController.instantiate()
        vc.viewModel = viewModel
        return vc
    }
}

// MARK: - View Lifecycle

extension AgencyDetailViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupRx()
        setupUI()
    }
}

// MARK: - Private methods

extension AgencyDetailViewController {
    private func setupTableView() {
        // Configure TableView
        tableView.tableFooterView = UIView()
        tableView.dataSource = datasource
        tableView.delaysContentTouches = false
    }
    
    private func setupUI() {
        datasource.load(agency: viewModel.outputs.agency)
        tableView.reloadData()
    }
    
    private func setupRx() {
        // Back button
        backButton.rx.tap.throttle(0.5, scheduler: MainScheduler.instance)
            .bind { [unowned self] _ in
                self.navigationDelegate?.pop()
            }
            .disposed(by: disposeBag)
    }
}
