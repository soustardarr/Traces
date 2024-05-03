//
//  RegistrationControllerCoordinator.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 01.05.2024.
//

import Foundation
import UIKit

class RegistrationControllerCoordinator: BaseCoordinator {

    private var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        let regController = RegistrationController()
        regController.registrationControllerCoordinator = self
        navigationController.pushViewController(regController, animated: true)
    }

    func dismissToLastVC() {
        navigationController.popViewController(animated: true)
        remove(coordinator: self)
    }

}
