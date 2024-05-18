//
//  MainControllerCoordinator.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 01.05.2024.
//

import Foundation
import UIKit

class MainControllerCoordinator: BaseCoordinator {

    private var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        let mainController = MainController()
        mainController.mainControllerCoordinator = self
        navigationController.pushViewController(mainController, animated: true)
    }
    
    override func startWithDeeplinkVC(_ viewController: UIViewController) {
        let mainController = MainController(deepLinkVC: viewController)
        mainController.mainControllerCoordinator = self
        navigationController.pushViewController(mainController, animated: true)
        
    }


}
