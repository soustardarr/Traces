//
//  PeopleProfileView.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 02.05.2024.
//


import UIKit

protocol PeopleProfileViewDelegate: AnyObject {
    func didTappedFriendButton()
    func didTappedMessageButton()
}

class PeopleProfileView: UIView {

    weak var delegate: PeopleProfileViewDelegate?

    var avatarImageView: UIImageView = {
        let avatarImageView = UIImageView()
        avatarImageView.image = .profileIcon
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 60
        avatarImageView.layer.borderWidth = 2
        avatarImageView.layer.borderColor = UIColor.white.cgColor
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        return avatarImageView
    }()

    var nameLabel: UILabel = {
        var nameLabel = UILabel()
        nameLabel.text = "Some Name"
        nameLabel.font = UIFont.systemFont(ofSize: 20)
        nameLabel.textColor = .black
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        return nameLabel
    }()

    lazy var friendButton: UIButton = {
        let button = UIButton()
        button.setTitle("подписаться", for: .normal)
        button.layer.cornerRadius = 7
        button.clipsToBounds = true
        button.setTitleColor(.black, for: .normal)
        let action = UIAction { _ in self.delegate?.didTappedFriendButton() }
        button.addAction(action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    var buttonMessage: UIImageView = {
        let buttonMessage = UIImageView()
        let colorConfig = UIImage.SymbolConfiguration(paletteColors: [.systemIndigo])
        let messageImage = UIImage(systemName: "message.badge.circle.fill", withConfiguration: colorConfig)
        buttonMessage.image = messageImage
        buttonMessage.isUserInteractionEnabled = true
        buttonMessage.translatesAutoresizingMaskIntoConstraints = false
        return buttonMessage
    }()

    var iconApp: UIImageView = {
        let iconApp = UIImageView()
        iconApp.image = UIImage.iconApp
        iconApp.translatesAutoresizingMaskIntoConstraints = false
        return iconApp
    }()

    private func addGesture() {
        let gestureMessage = UITapGestureRecognizer(target: self, action: #selector(didTappedMessage))
        buttonMessage.addGestureRecognizer(gestureMessage)

    }

    @objc private func didTappedMessage() {
        delegate?.didTappedMessageButton()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        addGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func setupUI() {

        backgroundColor = .white
        addSubview(nameLabel)
        addSubview(avatarImageView)
        addSubview(buttonMessage)
        addSubview(friendButton)
        addSubview(iconApp)
        NSLayoutConstraint.activate([

            buttonMessage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            buttonMessage.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 30),
            buttonMessage.widthAnchor.constraint(equalToConstant: 36),
            buttonMessage.heightAnchor.constraint(equalToConstant: 36),


            avatarImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            avatarImageView.topAnchor.constraint(equalTo: buttonMessage.bottomAnchor, constant: 30),
            avatarImageView.widthAnchor.constraint(equalToConstant: 150),
            avatarImageView.heightAnchor.constraint(equalToConstant: 150),

            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 10),
            nameLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            friendButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            friendButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            friendButton.heightAnchor.constraint(equalToConstant: 35),
            friendButton.widthAnchor.constraint(equalToConstant: 200),

            iconApp.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconApp.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30)

        ])

    }

}
