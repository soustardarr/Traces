//
//  AnnotationView.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 03.05.2024.
//

import UIKit

class AnnotationView: UIView {

    var clearBackgroundContainer: UIView = {
        let backgroundView = UIView()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.backgroundColor = .clear
        backgroundView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        backgroundView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        return backgroundView
    }()
    var whiteBackgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.backgroundColor = .white
        backgroundView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        backgroundView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        backgroundView.clipsToBounds = true
        backgroundView.layer.cornerRadius = 24
        backgroundView.layer.borderWidth = 2
        backgroundView.layer.borderColor = UIColor.black.cgColor
        return backgroundView
    }()

    var avatarImageView: UIImageView = {
        let avatarImageView = UIImageView()
        avatarImageView.image = .add
        avatarImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 20
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        return avatarImageView
    }()

    var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.textColor = .black
        nameLabel.font = .systemFont(ofSize: 13)
        nameLabel.textAlignment = .center
        nameLabel.text = "name"
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        return nameLabel
    }()

    init(name: String, image: Data) {
        super.init(frame: .zero)
        doInMainThread {
            self.nameLabel.text = name
            self.avatarImageView.image = UIImage(data: image)
        }
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        addSubview(clearBackgroundContainer)
        clearBackgroundContainer.addSubview(whiteBackgroundView)
        whiteBackgroundView.addSubview(avatarImageView)
        clearBackgroundContainer.addSubview(nameLabel)
        NSLayoutConstraint.activate([

            clearBackgroundContainer.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            clearBackgroundContainer.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            whiteBackgroundView.centerXAnchor.constraint(equalTo: clearBackgroundContainer.centerXAnchor),
            whiteBackgroundView.centerYAnchor.constraint(equalTo: clearBackgroundContainer.centerYAnchor),

            avatarImageView.centerXAnchor.constraint(equalTo: whiteBackgroundView.centerXAnchor),
            avatarImageView.centerYAnchor.constraint(equalTo: whiteBackgroundView.centerYAnchor),

            nameLabel.topAnchor.constraint(equalTo: whiteBackgroundView.bottomAnchor),
            nameLabel.centerXAnchor.constraint(equalTo: whiteBackgroundView.centerXAnchor),
        ])
    }
}
