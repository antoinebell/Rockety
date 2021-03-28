//
//  AgencyDetailLaunchersTableViewCell.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 25.10.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation
import UIKit

class AgencyDetailLaunchersTableViewCell: UITableViewCell {
    // - Properties
    private var launchers = [AgencyLauncher]()
    
    // - Outlets
    @IBOutlet private var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupCollectionView()
    }
}

// MARK: - Private methods

extension AgencyDetailLaunchersTableViewCell {
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
    }
}

// MARK: - Configuration

extension AgencyDetailLaunchersTableViewCell: ValueCell {
    func configure(with value: [AgencyLauncher]) {
        launchers = value
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource / UICollectionViewDelegate

extension AgencyDetailLaunchersTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return launchers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AgencyDetailLauncherCollectionViewCell.cellIdentifier(), for: indexPath) as! AgencyDetailLauncherCollectionViewCell
        cell.configure(with: launchers[indexPath.row])
        return cell
    }
}
