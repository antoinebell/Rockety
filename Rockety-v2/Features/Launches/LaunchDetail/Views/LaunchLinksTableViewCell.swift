//
//  LaunchLinksTableViewCell.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 25.10.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

class LaunchLinksTableViewCell: UITableViewCell {
    // - Properties
    let disposeBag = DisposeBag()
    var onPressTap: (() -> Void)?
    var onYoutubeTap: (() -> Void)?
    
    // - Outlets
    @IBOutlet var pressButton: UIButton!
    @IBOutlet var youtubeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupRx()
    }
}

// MARK: - Private methods

extension LaunchLinksTableViewCell {
    private func setupRx() {
        pressButton.rx.tap.throttle(0.5, scheduler: MainScheduler.instance)
            .bind { [weak self] _ in
                self?.onPressTap?()
            }
            .disposed(by: disposeBag)
        
        youtubeButton.rx.tap.throttle(0.5, scheduler: MainScheduler.instance)
            .bind { [weak self] _ in
                self?.onYoutubeTap?()
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Configuration

extension LaunchLinksTableViewCell: ValueCell {
    struct Value {
        let onPressTap: (() -> Void)
        let onYoutubeTap: (() -> Void)
    }
    
    func configure(with value: Value) {
        onPressTap = value.onPressTap
        onYoutubeTap = value.onYoutubeTap
    }
}
