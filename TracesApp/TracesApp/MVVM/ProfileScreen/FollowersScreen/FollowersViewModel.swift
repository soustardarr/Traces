//
//  FollowersViewModel.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 03.06.2024.
//

import Foundation
import Combine

class FollowersViewModel {
    

    init() {
        getFollowersEmails()
    }

    var followersEmails: [String]? {
        didSet {
            getProfiles(emails: followersEmails ?? [])
        }
    }

    var followers: [User]? {
        didSet {
            getFollowers?(followers ?? [])
        }
    }

    var getFollowers: (([User]?) -> ())?


    func getFollowersEmails() {
        RealTimeDataBaseManager.shared.getFollowersEmails { emails in
            guard let emails = emails else { return }
            self.followersEmails = emails
        }
    }

    func getProfiles(emails: [String]) {
        let dispatchGroup = DispatchGroup()
        var users = [User]()
        let selfEmail = UserDefaults.standard.string(forKey: "safeEmail") ?? ""
        emails.forEach { email in
            dispatchGroup.enter()
            RealTimeDataBaseManager.shared.getProfileInfo(safeEmail: email) { result in
                defer {
                    dispatchGroup.leave()
                }
                switch result {
                case .success(let user):
                    if user.friends?.contains(where: { $0 == selfEmail }) != true {
                        users.append(user)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            self.followers = users
        }
    }

    func addFriend(user: User) {
        let selfEmail = UserDefaults.standard.string(forKey: "safeEmail") ?? ""
        RealTimeDataBaseManager.shared.addFollow(for: user) { friend in
            var friend1 = friend
            friend1?.subscriptions = [ selfEmail ]

            if ObtainFriendManager.shared.generalFriends != nil {
                ObtainFriendManager.shared.generalFriends?.append(friend1 ?? User(name: "", email: ""))
            } else {
                if let friend1 = friend1 {
                    ObtainFriendManager.shared.generalFriends = [ friend1 ]
                }
            }
        }
        RealTimeDataBaseManager.shared.addToFriendsList(selfEmail, user.safeEmail)
    }

}
