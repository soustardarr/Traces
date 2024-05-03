//
//  ViewController.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 30.04.2024.
//

import UIKit

class AuthorizationController: UIViewController {

    weak var authorizationControllerCoordinator: AuthorizationControllerCoordinator?
    private var authView: AuthorizationView?
    private var authorizationViewModel: AuthorizationViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
        authView = AuthorizationView()
        authView?.delegate = self
        view = authView
        authorizationViewModel = AuthorizationViewModel()
    }

    private func alertUserLoginError() {
        authView?.resignResponders()
        let alertController = UIAlertController(title: "Ошибка!", message: "проверьте правильность email или пароля", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "ок", style: .cancel))
        present(alertController, animated: true)
    }

}

extension AuthorizationController: AuthorizationViewDelegate {
    func didLoginButtonTapped(email: String, password: String) {
        authorizationViewModel?.didLoginAccount(email, password, completion: { [ weak self ] boolResult in
            if boolResult {
                self?.authorizationControllerCoordinator?.runMainScreen()
            } else {
                self?.alertUserLoginError()
            }
        })
    }




    func didTapRegister() {
        authorizationControllerCoordinator?.runRegistration()
    }


}

