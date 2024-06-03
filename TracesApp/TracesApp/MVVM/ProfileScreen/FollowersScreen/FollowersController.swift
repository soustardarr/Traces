//
//  FollowersController.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 03.06.2024.
//

import UIKit

class FollowersController: UIViewController {

    private var viewModel: FollowersViewModel?
    private var followersView: FollowersView?
    private var followers: [User]?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        obtainFollowers()
    }

    private func setup() {
        viewModel = FollowersViewModel()
        followersView = FollowersView()
        followersView?.tableView.delegate = self
        followersView?.tableView.dataSource = self
        followersView?.tableView.register(FollowersViewCell.self, forCellReuseIdentifier: FollowersViewCell.reuseIdentifier)
        view = followersView
    }

    private func obtainFollowers() {
        viewModel?.getFollowers = { [ weak self ] users in
            doInMainThread {
                self?.followers = users
                self?.followersView?.tableView.reloadData()
            }

        }
    }


}


extension FollowersController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

extension FollowersController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        followers?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FollowersViewCell.reuseIdentifier, for: indexPath) as? FollowersViewCell
        if let follower = followers?[indexPath.row] {
            cell?.config(with: follower)
        }
        cell?.delegate = self
        return cell ?? UITableViewCell()
    }
}


extension FollowersController: FollowersViewCellDelegate {
    func didTapAddFollower(user: User) {
        viewModel?.addFriend(user: user)
        followers?.removeAll(where: { $0.safeEmail == user.safeEmail })
        followersView?.tableView.reloadData()

    }
}
