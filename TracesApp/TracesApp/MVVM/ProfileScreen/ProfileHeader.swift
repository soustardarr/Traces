//
//  ProfileHeader.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 01.05.2024.
//

import UIKit

protocol HeaderViewDelegate: AnyObject {
//    func didTappedSignOutButton()
//    func didTappedCreatePublication()
}

class HeaderView: UITableViewHeaderFooterView {

    weak var delegate: HeaderViewDelegate?

    var backgroundViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var avatarImageView: UIImageView = {
        let avatarImageView = UIImageView()
        avatarImageView.image = .profileIcon
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 60
        avatarImageView.layer.borderWidth = 3
        avatarImageView.layer.borderColor = UIColor.black.cgColor
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        return avatarImageView
    }()

    var nameLabel: UILabel = {
        var nameLabel = UILabel()
        nameLabel.text = "Name"
        nameLabel.font = UIFont.systemFont(ofSize: 20)
        nameLabel.textColor = .black
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        return nameLabel
    }()

    var createPublicationButton: UIImageView = {
        let addPublicationButton = UIImageView()
        let colorConfig = UIImage.SymbolConfiguration(paletteColors: [.black])
        let settingsImage = UIImage(systemName: "pencil.tip.crop.circle.badge.plus", withConfiguration: colorConfig)
        addPublicationButton.image = settingsImage
        addPublicationButton.isUserInteractionEnabled = true
        addPublicationButton.translatesAutoresizingMaskIntoConstraints = false
        return addPublicationButton
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    private func addGesture() {
//        let exitGesture = UITapGestureRecognizer(target: self, action: #selector(handleExitGesture))
//        exitButton.addGestureRecognizer(exitGesture)
//
//        let createGesture = UITapGestureRecognizer(target: self, action: #selector(handleCreateGesture))
//        createPublicationButton.addGestureRecognizer(createGesture)
//
//    }
//
//    @objc private func handleExitGesture() {
//        delegate?.didTappedSignOutButton()
//    }
//    @objc private func handleCreateGesture() {
//        delegate?.didTappedCreatePublication()
//    }

    private func setupUI() {
        contentView.addSubview(backgroundViewContainer)
        backgroundViewContainer.addSubview(nameLabel)
        backgroundViewContainer.addSubview(avatarImageView)
        backgroundViewContainer.addSubview(createPublicationButton)

        NSLayoutConstraint.activate([
                backgroundViewContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
                backgroundViewContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
                backgroundViewContainer.topAnchor.constraint(equalTo: topAnchor),
                backgroundViewContainer.bottomAnchor.constraint(equalTo: bottomAnchor),

                avatarImageView.centerXAnchor.constraint(equalTo: backgroundViewContainer.centerXAnchor),
                avatarImageView.centerYAnchor.constraint(equalTo: backgroundViewContainer.centerYAnchor),
                avatarImageView.widthAnchor.constraint(equalToConstant: 150),
                avatarImageView.heightAnchor.constraint(equalToConstant: 150),

                nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 20),
                nameLabel.centerXAnchor.constraint(equalTo: backgroundViewContainer.centerXAnchor),


                createPublicationButton.topAnchor.constraint(equalTo: backgroundViewContainer.safeAreaLayoutGuide.topAnchor),
                createPublicationButton.trailingAnchor.constraint(equalTo: backgroundViewContainer.trailingAnchor, constant: -30),
                createPublicationButton.heightAnchor.constraint(equalToConstant: 33),
                createPublicationButton.widthAnchor.constraint(equalToConstant: 33),

            ])
    }
}
