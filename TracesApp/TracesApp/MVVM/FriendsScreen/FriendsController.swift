//
//  FriendsController.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 02.05.2024.
//

import UIKit
import Combine
import SwiftUI

class FriendsController: UIViewController {

    private var friendsView: FriendsView?
    private var friendsViewModel: FriendsViewModel?

    var results: [User]!
    var friends: [User] = []
    var cancellable: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.isHidden = false
        setupNavigationBar()
    }

    private func setup() {
        friendsView = FriendsView()
        view = friendsView
        friendsViewModel = FriendsViewModel()
        setupTableViews()
        setupDataFriends()
        setupDataPeople()
    }

    private func setupDataPeople() {
        friendsViewModel?.$results
            .sink(receiveValue: { [ weak self ] users in
                self?.results = users
                self?.friendsView?.peopleTableView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: DispatchWorkItem(block: {
                    self?.friendsView?.hud.dismiss()
                }))
            })
            .store(in: &cancellable)
    }

    private func setupDataFriends() {
        ObtainFriendManager.shared.$generalFriends 
            .sink { friends in
                DispatchQueue.main.async {
                    self.friends = friends ?? []
                    self.friendsView?.friendsTableView.reloadData()
                }
            }
            .store(in: &cancellable)
    }

    private func setupTableViews() {
        friendsView?.peopleTableView.delegate = self
        friendsView?.peopleTableView.dataSource = self
        friendsView?.peopleTableView.register(PeopleViewCell.self, forCellReuseIdentifier: PeopleViewCell.reuseIdentifier)

        friendsView?.friendsTableView.delegate = self
        friendsView?.friendsTableView.dataSource = self
        friendsView?.friendsTableView.register(FriendsViewCell.self, forCellReuseIdentifier: FriendsViewCell.reuseIdentifier)
    }


    private func setupNavigationBar() {
        friendsView?.searchBar.delegate = self
        navigationController?.navigationBar.topItem?.titleView = friendsView?.searchBar
        let rightBarButton = UIBarButtonItem(title: "отмена",
                                             style: .done,
                                             target: self,
                                             action: #selector(didCancelTapped))
        rightBarButton.tintColor = .black
        navigationController?.navigationBar.topItem?.rightBarButtonItem = rightBarButton
    }

    @objc func didCancelTapped() {
        friendsView?.searchBar.text = ""
        friendsView?.friendsTableView.isHidden = false
        friendsView?.friendsLabel.isHidden = false
        friendsView?.noFriendsLabel.isHidden = true
        friendsView?.peopleTableView.isHidden = true
        friendsView?.searchBar.resignFirstResponder()
    }

}

extension FriendsController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        friendsView?.friendsTableView.isHidden = true
        friendsView?.friendsLabel.isHidden = true
        if let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty {
            searchBar.resignFirstResponder()
            friendsView?.friendsTableView.isHidden = true
            friendsView?.friendsLabel.isHidden = true
            friendsViewModel?.results?.removeAll()
            friendsView?.hud.show(in: view, animated: true)
            friendsViewModel?.searchUsers(text: text)
            friendsView?.hud.dismiss()
            updateUI()
            friendsView?.peopleTableView.reloadData()
        }
    }

    func updateUI() {
        if friendsViewModel!.results?.isEmpty == true {
            friendsView?.noFriendsLabel.isHidden = false
            friendsView?.peopleTableView.isHidden = true
        } else {
            friendsView?.noFriendsLabel.isHidden = true
            friendsView?.peopleTableView.isHidden = false
            friendsView?.peopleTableView.reloadData()
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            if searchText.isEmpty {
                friendsView?.friendsTableView.isHidden = false
                friendsView?.friendsLabel.isHidden = false

                friendsView?.noFriendsLabel.isHidden = true
                friendsView?.peopleTableView.isHidden = true
            }
        }

}


extension FriendsController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == friendsView?.friendsTableView {
            return friends.count
        } else if tableView == friendsView?.peopleTableView {
            if self.results != nil {
                return self.results.count
            }
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if tableView == friendsView?.friendsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: FriendsViewCell.reuseIdentifier, for: indexPath) as? FriendsViewCell
            cell?.config(with: friends[indexPath.row])
            cell?.delegate = self 
            return cell ?? UITableViewCell()
        } else if tableView == friendsView?.peopleTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: PeopleViewCell.reuseIdentifier, for: indexPath) as? PeopleViewCell
            if results != nil {
                let name = results[indexPath.row].name
                let email = results[indexPath.row].email
                let friends = results[indexPath.row].friends
                let sub = results[indexPath.row].subscriptions
                let followers = results[indexPath.row].followers
                friendsViewModel?.getImage(pictureFileName: results[indexPath.row].profilePictureFileName, completion: { image in
                    let user = User(name: name, email: email, profilePicture: image, friends: friends, followers: followers, subscriptions: sub)
                    cell?.config(with: user)
                })
                return cell ?? UITableViewCell()
            }
        }
        return UITableViewCell()
    }

}

extension FriendsController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if tableView == friendsView?.friendsTableView {
            if let cell = tableView.cellForRow(at: indexPath) as? FriendsViewCell {
                guard let avatarImage = cell.avatarImageView.image else { return }
                let vc = PeopleProfileController(avatarimage: avatarImage, currentUser: friends[indexPath.row])
                self.present(vc, animated: true)
            }
        } else if tableView == friendsView?.peopleTableView {
            if let cell = tableView.cellForRow(at: indexPath) as? PeopleViewCell {
                guard let avatarImage = cell.avatarImageView.image else { return }
                let vc = PeopleProfileController(avatarimage: avatarImage, currentUser: results[indexPath.row])
                vc.delegate = self
                self.present(vc, animated: true)
            }
        }
    }

}


extension FriendsController: PeopleProfileControllerDelegate {
    func updateUser(user: User) {
        friendsViewModel?.results?.removeAll(where: { $0.safeEmail == user.safeEmail })
        friendsViewModel?.results?.append(user)

        friendsViewModel?.users.removeAll(where: { $0.safeEmail == user.safeEmail })
        friendsViewModel?.users.append(user)

        results?.removeAll(where: { $0.safeEmail == user.safeEmail })
        results?.append(user)
    }
}


extension FriendsController: FriendsViewCellDelegate {
    func didTappedMessageButton(user: User) {
        let chatController = UIHostingController(rootView: LogChatSUIView(user: user))
        let navVC = UINavigationController(rootViewController: chatController)
        navVC.title = user.name
        present(navVC, animated: true)
    }
}
