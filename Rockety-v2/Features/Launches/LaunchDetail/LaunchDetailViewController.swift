//
//  LaunchDetailViewController.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 24.10.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

protocol LaunchDetailNavigationDelegate: class {
    func pop()
    func openLink(url: URL)
    func showNoLink(sender: LaunchDetailViewController)
    func showCalendarAuthorizationDenied(sender: LaunchDetailViewController)
    func showCalendarAuthorizationNotDetermined(sender: LaunchDetailViewController, onAccept: @escaping (() -> Void))
    func showEventAdded(sender: LaunchDetailViewController)
    func showEventAddedError(sender: LaunchDetailViewController)
}

class LaunchDetailViewController: BaseViewController {
    // - Properties
    private var viewModel: LaunchDetailViewModelType!
    private let datasource = LaunchDetailDataSource()
    weak var navigationDelegate: LaunchDetailNavigationDelegate?
    
    // - Outlets
    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var calendarButton: UIButton!
    @IBOutlet private var tableView: UITableView!
    
    // - Initializer
    static func instantiate(withViewModel viewModel: LaunchDetailViewModelType) -> LaunchDetailViewController {
        let vc: LaunchDetailViewController = LaunchDetailViewController.instantiate()
        vc.viewModel = viewModel
        return vc
    }
}

// MARK: - View Lifecycle

extension LaunchDetailViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupRx()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.inputs.viewDidAppear()
    }
}

// MARK: - Private Methods

extension LaunchDetailViewController {
    private func setupTableView() {
        // Configure TableView
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        tableView.dataSource = datasource
        tableView.delaysContentTouches = false
    }

    private func setupRx() {
        // Back button
        backButton.rx.tap.throttle(0.5, scheduler: MainScheduler.instance)
            .bind { [unowned self] _ in
                self.navigationDelegate?.pop()
            }
            .disposed(by: disposeBag)
        
        // Calendar button
        calendarButton.rx.tap.throttle(0.5, scheduler: MainScheduler.instance)
            .bind { [unowned self] _ in
                self.viewModel.inputs.addEventToCalendar()
            }
            .disposed(by: disposeBag)
        
        viewModel.outputs.calendarButtonImage
            .unwrap()
            .drive(calendarButton.rx.image(for: .normal))
            .disposed(by: disposeBag)
        
        viewModel.outputs.calendarButtonIsEnabled
            .unwrap()
            .drive(calendarButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // Calendar events
        viewModel.outputs.calendarAuthorizationDenied
            .asObservable()
            .map { [weak self] in
                guard let self = self else { return nil }
                return self
            }
            .unwrap()
            .subscribe(onNext: navigationDelegate?.showCalendarAuthorizationDenied(sender:))
            .disposed(by: disposeBag)
        
        viewModel.outputs.calendarAuthorizationNotDetermined
            .asObservable()
            .bind { [unowned self] _ in
                let onAccept: (() -> Void) = {
                    self.viewModel.inputs.addEventToCalendar()
                }
                self.navigationDelegate?.showCalendarAuthorizationNotDetermined(sender: self, onAccept: onAccept)
            }
            .disposed(by: disposeBag)
        
        // Events
        viewModel.outputs.eventAdded
            .asObservable()
            .map { [weak self] in
                guard let self = self else { return nil }
                return self
            }
            .unwrap()
            .subscribe(onNext: navigationDelegate?.showEventAdded(sender:))
            .disposed(by: disposeBag)
        
        viewModel.outputs.eventAddedError
            .asObservable()
            .map { [weak self] in
                guard let self = self else { return nil }
                return self
            }
            .unwrap()
            .subscribe(onNext: navigationDelegate?.showEventAddedError(sender:))
            .disposed(by: disposeBag)
    }

    private func setupUI() {
        // View
        view.backgroundColor = UIColor(named: "Background")
        
        // Datasource
        datasource.delegate = self
        datasource.load(withLaunch: viewModel.outputs.launch)
        tableView.reloadData()
    }
}

// MARK: - LaunchDetailDataSourceDelegate

extension LaunchDetailViewController: LaunchDetailDataSourceDelegate {
    func openLink(url: URL) {
        navigationDelegate?.openLink(url: url)
    }
    
    func showNoLink() {
        navigationDelegate?.showNoLink(sender: self)
    }
}
