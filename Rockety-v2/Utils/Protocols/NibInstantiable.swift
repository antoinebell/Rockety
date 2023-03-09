//
//  NibInstantiable.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 06.08.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import UIKit

// MARK: Protocol Definition

/// Make your UIView subclasses conform to this protocol when:
///  * they *are* NIB-based, and
///  * this class is used as the XIB's root view
///
/// to be able to instantiate them from the NIB in a type-safe manner
protocol NibInstantiable: class {

    /// The nib file to use to load a new instance of the View designed in a XIB
    static var nibInstance: UINib { get }
}

// MARK: Default implementation

extension NibInstantiable {

    /// By default, use the nib which have the same name as the name of the class,
    /// and located in the bundle of that class
    static var nibInstance: UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
}

// MARK: Support for instantiation from NIB

extension NibInstantiable where Self: UIView {

    /// Returns a `UIView` object instantiated from nib
    ///
    /// - returns: A `NibInstantiable`, `UIView` instance
    static func instantiate() -> Self {
        guard let view = nibInstance.instantiate(withOwner: nil, options: nil).first as? Self else {
            fatalError("The nib \(nibInstance) expected its root view to be of type \(self)")
        }
        return view
    }
}
