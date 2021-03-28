//
//  CellIdentifiable.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 06.08.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation

/// The CellIdentifiable protocol gives any class that conforms to it (normally a UITableViewCell
/// or UICollectionViewCell) a *cellIdentifier()* method that can be used to identify that cell on Xib files or Storyboards.
/// - Important: When a new cell conforms to **CellIdentifiable** you must assign the same class name to the Xib/Storyboard instance of the cell.
protocol CellIdentifiable {
    /// Returns the cell identifier for the cell conforming to this protocol.
    static func cellIdentifier() -> String
}

extension CellIdentifiable {
    /// Returns a default cellIdentifier String to be used when looking for a cell (for TableViews or CollectionViews).
    /// The default value is the name of the class
    static func cellIdentifier() -> String {
        return String(describing: self)
    }
}
