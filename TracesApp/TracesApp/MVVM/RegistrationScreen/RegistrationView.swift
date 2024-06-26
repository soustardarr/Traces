//
//  RegistrationView.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 01.05.2024.
//

import UIKit
import JGProgressHUD

protocol RegistrationViewDelegate: AnyObject {

    func doneSignUpButtonTapped()

}

class RegistrationView: UIView {

    weak var delegate: RegistrationViewDelegate?
    var hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .light)
        return hud
    }()

    var addPhotoLabel: UILabel = {
        let label = UILabel()
        label.text = "установить фото:"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var avatarImageView: UIImageView = {
        let avatarImageView = UIImageView()
        avatarImageView.image = UIImage(systemName: "person.circle.fill")
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.cornerRadius = 60
        avatarImageView.layer.borderWidth = 2
        avatarImageView.layer.borderColor = UIColor.white.cgColor
        avatarImageView.isUserInteractionEnabled = true
        return avatarImageView
    }()

    var fieldStackView: UIStackView = {
        let fieldStackView = UIStackView()
        fieldStackView.axis = .vertical
        fieldStackView.spacing = 10
        fieldStackView.alignment = .fill
        fieldStackView.distribution = .fillEqually
        fieldStackView.translatesAutoresizingMaskIntoConstraints = false
        return fieldStackView
    }()

    var nameTextField: UITextField = {
        let nameTextField = UITextField()
        nameTextField.backgroundColor = .white
        nameTextField.placeholder = "твой никнейм..."
        nameTextField.autocorrectionType = .no
        nameTextField.autocapitalizationType = .none
        nameTextField.returnKeyType = .continue
        nameTextField.textColor = .black
        nameTextField.borderStyle = .roundedRect
        return nameTextField
    }()

    var loginTextField: UITextField = {
        let loginTextField = UITextField()
        loginTextField.keyboardType = .emailAddress
        loginTextField.backgroundColor = .white
        loginTextField.placeholder = "email..."
        loginTextField.autocorrectionType = .no
        loginTextField.autocapitalizationType = .none
        loginTextField.returnKeyType = .continue
        loginTextField.textColor = .black

        loginTextField.borderStyle = .roundedRect
        return loginTextField
    }()

    var passwordTextField: UITextField = {
        let passwordTextField = UITextField()
        passwordTextField.keyboardType = .default
        passwordTextField.backgroundColor = .white
        passwordTextField.placeholder = "пароль..."
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.autocorrectionType = .no
        passwordTextField.autocapitalizationType = .none
        passwordTextField.returnKeyType = .continue
        passwordTextField.textColor = .black
        passwordTextField.isSecureTextEntry = true
        return passwordTextField
    }()

    var secondPasswordTextField: UITextField = {
        let passwordTextField = UITextField()
        passwordTextField.keyboardType = .default
        passwordTextField.backgroundColor = .white
        passwordTextField.placeholder = "пароль второй раз..."
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.autocorrectionType = .no
        passwordTextField.autocapitalizationType = .none
        passwordTextField.returnKeyType = .done
        passwordTextField.textColor = .black
        passwordTextField.isSecureTextEntry = true
        return passwordTextField
    }()


    lazy var doneSignUpButton: UIButton = {
        let button = UIButton()
        button.setTitle("готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        let action = UIAction { _ in self.delegate?.doneSignUpButtonTapped() }
        button.addAction(action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupTextFieldDelegate()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func resignResponder() {
        nameTextField.resignFirstResponder()
        loginTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        secondPasswordTextField.resignFirstResponder()
    }

    private func setupTextFieldDelegate() {
        nameTextField.delegate = self
        loginTextField.delegate = self
        passwordTextField.delegate = self
        secondPasswordTextField.delegate = self
    }

    private func setupUI() {

        backgroundColor = .systemIndigo
        addSubview(avatarImageView)
        fieldStackView.addArrangedSubview(nameTextField)
        fieldStackView.addArrangedSubview(loginTextField)
        fieldStackView.addArrangedSubview(passwordTextField)
        fieldStackView.addArrangedSubview(secondPasswordTextField)
        addSubview(fieldStackView)
        addSubview(doneSignUpButton)
        addSubview(addPhotoLabel)


        NSLayoutConstraint.activate([

            addPhotoLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            addPhotoLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            avatarImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            avatarImageView.topAnchor.constraint(equalTo: addPhotoLabel.bottomAnchor, constant: 10),
            avatarImageView.widthAnchor.constraint(equalToConstant: 120),
            avatarImageView.heightAnchor.constraint(equalToConstant: 120),

            fieldStackView.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 10),
            fieldStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            fieldStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),

            doneSignUpButton.topAnchor.constraint(equalTo: fieldStackView.bottomAnchor, constant: 20),
            doneSignUpButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            doneSignUpButton.widthAnchor.constraint(equalToConstant: 150),
            doneSignUpButton.heightAnchor.constraint(equalToConstant: 50)

        ])

    }


}

extension RegistrationView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            loginTextField.becomeFirstResponder()
        } else if textField == loginTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            secondPasswordTextField.becomeFirstResponder()
        } else if secondPasswordTextField == textField {
            self.delegate?.doneSignUpButtonTapped()
        }
        return true
    }
}
