//
//  Coordinator.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 24.10.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import Foundation
import RxSwift

protocol Coordinator: AnyObject {
    // To store any child coordinators.
    var childCoordinators: [Coordinator] { get set }

    /// The start method gives control to the coordinator, allowing for extra customization and setup.
    func start()
    
    /// Request for dismissing the coordinator and its children, called usually by a parent coordinator for navigation purposes.
    func dismiss()
}

extension Coordinator {
    
    /// Adds a child to the stack of child coordinators.
    func storeChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }
    
    /// Removes a child from the stack of child coordinators.
    func freeChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
    }
    
    /// Dismisses all child coordinators.
    func dismissChildCoordinators() {
        childCoordinators.reversed().forEach { $0.dismiss() }
    }
    
    /// - Returns: the topmost child coordinator of a given type.
    func topChildCoordinator<T: Coordinator>(ofType: T.Type = T.self) -> T? {
        return childCoordinators.filter({ $0 is T }).last as? T
    }
}
