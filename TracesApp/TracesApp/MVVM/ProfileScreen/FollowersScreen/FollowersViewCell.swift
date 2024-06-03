//
//  FollowersViewCell.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 03.06.2024.
//

import UIKit

protocol FollowersViewCellDelegate: AnyObject {
    func didTapAddFollower(user: User)
}

class FollowersViewCell: UITableViewCell {

    weak var delegate: FollowersViewCellDelegate?

    var user: User?

    var avatarImageView: UIImageView = {
        let avatarImageView = UIImageView()
        let config = UIImage.SymbolConfiguration(paletteColors: [.black, .white])
        avatarImageView.image = UIImage(systemName: "person.crop.circle.fill", withConfiguration: config)
        avatarImageView.layer.cornerRadius = 15
        avatarImageView.clipsToBounds = true
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        return avatarImageView
    }()

    var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "friend"
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var messageButton: UIImageView = {
        let messageButton = UIImageView()
        let config = UIImage.SymbolConfiguration(paletteColors: [.systemIndigo])
        let image = UIImage(systemName: "plus.diamond.fill", withConfiguration: config)
        messageButton.image = image
        messageButton.isUserInteractionEnabled = true
        messageButton.translatesAutoresizingMaskIntoConstraints = false
        return messageButton
    }()

    func config(with user: User) {
        DispatchQueue.main.async {
            self.user = user
            self.avatarImageView.image = UIImage(data: user.profilePicture ?? Data()) ?? .profileIcon
            self.nameLabel.textColor = .black
            self.nameLabel.text = user.name
        }
    }

    private func addGesture() {
        let gestureMessage = UITapGestureRecognizer(target: self, action: #selector(didTappedMessage))
        messageButton.addGestureRecognizer(gestureMessage)

    }

    @objc private func didTappedMessage() {
        delegate?.didTapAddFollower(user: user ?? User(name: "", email: ""))
    }


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        addGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.backgroundColor = .white
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(messageButton)

        NSLayoutConstraint.activate([
            avatarImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            avatarImageView.widthAnchor.constraint(equalToConstant: 30),
            avatarImageView.heightAnchor.constraint(equalToConstant: 30),

            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 30),

            messageButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            messageButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            messageButton.widthAnchor.constraint(equalToConstant: 30),
            messageButton.heightAnchor.constraint(equalToConstant: 30),
        ])

    }


}
