//
//  StoryboardInstantiable.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 24.10.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation
import UIKit

/// Protocol to give any class that conform it a static variable `storyboardIdentifier`
protocol StoryboardInstantiable: class {
    static var storyboardInstance: UIStoryboard { get }
}

/// Protocol extension to implement `storyboardIdentifier` variable only when `Self` is of type `UIViewController`
extension StoryboardInstantiable where Self: UIViewController {
    static var storyboardIdentifier: String {
        return String(describing: self)
    }

    /// Returns a storyboard file instance based on the ViewController storyboard identifier property
    static var storyboardInstance: UIStoryboard {
        return UIStoryboard(name: storyboardIdentifier, bundle: Bundle(for: BaseViewController.self))
    }

    ///
    /// Create an instance of the ViewController from its associated storyboard.
    ///
    /// - returns: instance of the conforming ViewController
    static func instantiate() -> Self {
        let viewController = storyboardInstance.instantiateViewController(withIdentifier: storyboardIdentifier)
        guard let typedViewController = viewController as? Self else {
            fatalError("The viewController '\(storyboardIdentifier)' of '\(storyboardInstance)' is not of class '\(self)'")
        }
        return typedViewController
    }
}
