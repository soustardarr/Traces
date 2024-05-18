//
//  AppCoordinator.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 17.04.2024.
//

import Foundation
import UIKit
import FirebaseAuth

class AppCoordinator: BaseCoordinator {

    static let shared = AppCoordinator()

    var window: UIWindow?
    private var navigationController: UINavigationController?

    override func start() {
        childCoordinators.removeAll()
        guard let window = window else {
            fatalError("Window is not set for AppCoordinator. Please set the window property before calling start.")
        }

        navigationController = UINavigationController()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        if FirebaseAuth.Auth.auth().currentUser != nil {
            let mainCoordinator = MainControllerCoordinator(navigationController: navigationController ?? UINavigationController())
            add(coorfinator: mainCoordinator)
            mainCoordinator.start()

        } else {
            let authorizationViewContollerCoordinator = AuthorizationControllerCoordinator(navigationController: navigationController ?? UINavigationController())
            add(coorfinator: authorizationViewContollerCoordinator)
            authorizationViewContollerCoordinator.start()
        }
    }

    override func startWithDeeplinkVC(_ viewController: UIViewController) {
        childCoordinators.removeAll()
        guard let window = window else {
            fatalError("Window is not set for AppCoordinator. Please set the window property before calling start.")
        }

        navigationController = UINavigationController()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        if FirebaseAuth.Auth.auth().currentUser != nil {
            let mainCoordinator = MainControllerCoordinator(navigationController: navigationController ?? UINavigationController())
            add(coorfinator: mainCoordinator)
            mainCoordinator.startWithDeeplinkVC(viewController)

        } else {
            let authorizationViewContollerCoordinator = AuthorizationControllerCoordinator(navigationController: navigationController ?? UINavigationController())
            add(coorfinator: authorizationViewContollerCoordinator)
            authorizationViewContollerCoordinator.start()
        }

    }

}
