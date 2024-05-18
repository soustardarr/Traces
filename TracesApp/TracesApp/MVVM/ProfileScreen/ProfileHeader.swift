//
//  ProfileHeader.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 01.05.2024.
//

import UIKit

protocol HeaderViewDelegate: AnyObject {
    func didTappedShareProfile()
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

    lazy var shareProfileButton: UIButton = {
        let shareProfileButton = UIButton()
        shareProfileButton.setTitle(" поделись профилем!", for: .normal)
        let colorConfig = UIImage.SymbolConfiguration(paletteColors: [.white])
        let image = UIImage(systemName: "doc.on.doc", withConfiguration: colorConfig)
        shareProfileButton.setImage(image, for: .normal)
        shareProfileButton.contentHorizontalAlignment = .center
        shareProfileButton.clipsToBounds = true
        shareProfileButton.layer.cornerRadius = 10
        shareProfileButton.backgroundColor = .systemIndigo
        shareProfileButton.translatesAutoresizingMaskIntoConstraints = false
        shareProfileButton.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 20)
        let action = UIAction { _ in self.delegate?.didTappedShareProfile() }
        shareProfileButton.addAction(action, for: .touchUpInside)
        return shareProfileButton
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(backgroundViewContainer)
        backgroundViewContainer.addSubview(nameLabel)
        backgroundViewContainer.addSubview(avatarImageView)
        backgroundViewContainer.addSubview(shareProfileButton)

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

                shareProfileButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 30),
                shareProfileButton.leadingAnchor.constraint(equalTo: backgroundViewContainer.leadingAnchor, constant: 30),
                shareProfileButton.widthAnchor.constraint(equalToConstant: 225),
                shareProfileButton.heightAnchor.constraint(equalToConstant: 50)
            ])
    }
}
