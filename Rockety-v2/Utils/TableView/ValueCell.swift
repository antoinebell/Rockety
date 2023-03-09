//
//  ValueCell.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 06.08.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//
//  Source: https://github.com/kickstarter/ios-oss/blob/master/Library/DataSource/ValueCell.swift

/// A type that represents a cell that can be reused and configured with a value.
protocol ValueCell: CellIdentifiable {
    associatedtype Value
    func configure(with value: Value)
}
