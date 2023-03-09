//
//  AgenciesViewController.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 25.10.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation
import UIKit

protocol AgenciesNavigationDelegate: class {
    func showDetail(agency: Agency)
}

class AgenciesViewController: BaseViewController {
    // - Properties
    private let viewModel: AgenciesViewModelType = AgenciesViewModel()
    private let datasource = AgenciesDataSource()
    weak var navigationDelegate: AgenciesNavigationDelegate?
    private let refreshControl = UIRefreshControl()
    
    // - Outlets
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var searchBar: UISearchBar!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
}

// MARK: - View Lifecycle

extension AgenciesViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupRx()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        viewModel.inputs.loadData()
    }
}

// MARK: - Private Methods

extension AgenciesViewController {
    private func setupTableView() {
        // Configure TableView
        tableView.tableFooterView = UIView()
        tableView.dataSource = datasource
        tableView.delaysContentTouches = false
    }

    private func setupRx() {
        // Bind activity
        bindActivity(viewModel.outputs, activityIndicator: activityIndicator)

        // Get launches
        viewModel.outputs.agencies
            .asObservable()
            .unwrap()
            .bind { [unowned self] agencies in
                self.updateUI(agencies: agencies.results)
            }
            .disposed(by: disposeBag)

        // Search
        searchBar.rx.text.orEmpty.distinctUntilChanged()
            .bind { [unowned self] text in
                self.viewModel.inputs.filterAgencies(query: text)
            }
            .disposed(by: disposeBag)
        
        searchBar.rx.searchButtonClicked
            .asDriver()
            .drive(onNext: { [unowned self] _ in
                self.searchBar.resignFirstResponder()
            })
            .disposed(by: disposeBag)
        
        // TableView
        tableView.rx.reachedBottom()
            .subscribe(onNext: viewModel.inputs.didScrollToBottom)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .asDriver()
            .drive(onNext: viewModel.inputs.rowSelected)
            .disposed(by: disposeBag)

        // Row Selected
        viewModel.outputs.rowSelected
            .asObservable()
            .unwrap()
            .bind { [unowned self] agency in
                self.navigationDelegate?.showDetail(agency: agency)
            }
            .disposed(by: disposeBag)
    }

    private func setupUI() {
        // View
        view.backgroundColor = UIColor(named: "Background")
        
        // Refresh Control
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: [NSAttributedString.Key.font: UIFont(name: "Barlow-Light", size: 17)!])
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        // Search Controller
        setupSearchBar()
        
        // Table View
        tableView.backgroundColor = UIColor(named: "Background")
    }

    private func updateUI(agencies: [Agency]) {
        if agencies.count > 0 {
            self.datasource.load(agencies: agencies)
            self.tableView.isHidden = false
            self.tableView.reloadData()
        } else {
            self.tableView.isHidden = true
        }
        self.refreshControl.endRefreshing()
    }

    private func setupSearchBar() {
        searchBar.barTintColor = UIColor(named: "Background")
        searchBar.showsCancelButton = false
        searchBar.placeholder = "Type in..."
    }
    
    @objc private func pullToRefresh() {
        viewModel.inputs.loadData()
    }
}
