//
//  PeopleProfileController.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 02.05.2024.
//

import UIKit
import Combine
import SwiftUI

protocol PeopleProfileControllerDelegate: AnyObject {
    func updateArray(user: User, status: FriendStatus)
}

class PeopleProfileController: UIViewController {

    private var peopleProfileView: PeopleProfileView?
    private var peopleProfileViewModel: PeopleProfileViewModel?
    private var avatarimage: UIImage
    private var currentUser: User
    private var cancellable: Set<AnyCancellable> = []
    weak var delegate: PeopleProfileControllerDelegate?


    init(avatarimage: UIImage, currentUser: User) {
        self.avatarimage = avatarimage
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
        peopleProfileView = PeopleProfileView()
        peopleProfileView?.delegate = self
        peopleProfileView?.avatarImageView.image = avatarimage
        peopleProfileView?.nameLabel.text = currentUser.name
        peopleProfileViewModel = PeopleProfileViewModel(currentUser: currentUser)

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        setupDataBindings()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let status = peopleProfileViewModel?.checkFriendStatus(with: currentUser) ?? .cleanStatus
        delegate?.updateArray(user: currentUser, status: status)
        print(currentUser)
    }

    private func setup() {
        view = peopleProfileView
    }

    private func setupDataBindings() {
        peopleProfileViewModel?.$currentUser
            .sink(receiveValue: { [ weak self ] user in
                guard let strongSelf = self else { return }
                let result = self?.peopleProfileViewModel?.checkFriendStatus(with: user)
                self?.currentUser = user
                self?.avatarimage = UIImage(data: user.profilePicture ?? Data()) ?? .profileIcon
                strongSelf.setupStatusFriendButton(result: result ?? .cleanStatus)
            })
            .store(in: &cancellable)
    }

    private func setupStatusFriendButton(result: FriendStatus? = nil) {
        guard result != nil else {
            let result = peopleProfileViewModel?.checkFriendStatus(with: currentUser)
            setupButton(result: result!)
            return
        }
        setupButton(result: result!)
    }

    private func setupButton(result: FriendStatus) {
        switch result {
        case .selfSubscribed:
            peopleProfileView?.friendButton.setTitle("отписаться", for: .normal)
            peopleProfileView?.friendButton.backgroundColor = .systemRed
        case .heSubscribedForSelf:
            peopleProfileView?.friendButton.setTitle("подписаться в ответ", for: .normal)
            peopleProfileView?.friendButton.backgroundColor = .systemBlue
        case .inFriends:
            peopleProfileView?.friendButton.setTitle("удалить из друзей", for: .normal)
            peopleProfileView?.friendButton.backgroundColor = .systemGray
        case .cleanStatus:
            peopleProfileView?.friendButton.setTitle("подписаться", for: .normal)
            peopleProfileView?.friendButton.backgroundColor = .systemGray
        }
    }

}

extension PeopleProfileController: PeopleProfileViewDelegate {

    func didTappedMessageButton() {
        let chatController = UIHostingController(rootView: LogChatSUIView(user: currentUser))
        let navVC = UINavigationController(rootViewController: chatController)
        navVC.title = currentUser.name
        present(navVC, animated: true)
    }
    
    func didTappedFriendButton() {
        peopleProfileViewModel?.changeFriendStatus()
        setupDataBindings()
        setupStatusFriendButton()
    }
}
