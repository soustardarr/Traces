//
//  LocationManager.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 02.05.2024.
//

import Foundation
import FirebaseDatabase
import Combine

enum LocationManagerError: Error {
    case failedReceivingFriendsEmails
}

class ObtainFriendManager {

    static let shared = ObtainFriendManager()

    let database = Database.database().reference()

    var locationObservers: [String: DatabaseHandle] = [:]

    private var cancellable = Set<AnyCancellable>()

    //    var friendsEmail: [String]? {
    //        didSet{
    //            self.obtainFriends(emails: self.friendsEmail ?? [])
    //        }
    //    }

    var friendsEmails: [String]? {
        didSet {
            self.obtainFriends(emails: friendsEmails ?? [])
        }
    }

    @Published var generalFriends: [User]? {
        didSet {
            //            print("\(generalFriends)!!!!!!!!!!!!!!!!")

            setupLocationObserver()
        }
    }

    var userLocationUpdate: User? {
        didSet {
            locationUpdateForActiveUser?(userLocationUpdate ?? User(name: "", email: ""))
        }
    }

    var locationUpdateForActiveUser: ((User) -> ())?


    func setupFriendsEmailsObserver() {
        guard let safeEmail = UserDefaults.standard.string(forKey: "safeEmail") else {
            return
        }
        database.child(safeEmail).child("friends").observe(.value) { snapshot in
            guard let emails = snapshot.value as? [String] else {
                return
            }
            if self.friendsEmails == nil {
                self.friendsEmails = emails
            } else {
                emails.forEach { email in
                    if let emailsArray = self.friendsEmails, !emailsArray.contains(email) {
                        self.friendsEmails?.append(email)
                    }
                }

            }
        }

    }


    //    func obtainEmails() {
    //        RealTimeDataBaseManager.shared.getEmailFriends { result in
    //            switch result {
    //            case .success(let emails):
    //                self.friendsEmail = emails
    //            case .failure(let error):
    //                print("не удалось получить емайлы друзей, error: \(error)")
    //            }
    //        }
    //
    //    }

    func obtainFriends(emails: [String]) {
        if generalFriends == nil {
            var users: [User] = []
            let dispatchGroup = DispatchGroup()
            for email in emails {
                dispatchGroup.enter()
                RealTimeDataBaseManager.shared.getProfileInfo(safeEmail: email) { result in
                    defer {
                        dispatchGroup.leave()
                    }
                    switch result {
                    case .success(let friend):
                        users.append(friend)
                    case .failure(let error):
                        print("ошибка получения друга: \(error)")
                    }
                }
            }
            dispatchGroup.notify(queue: .main) {
                self.generalFriends = users
            }

        } else {
            let friendsEmails = generalFriends?.compactMap { $0.safeEmail }
            let generalEmails = emails.filter { email in
                friendsEmails?.contains(email) == false
            }
            var users: [User] = []
            let dispatchGroup = DispatchGroup()
            for email in generalEmails {
                dispatchGroup.enter()
                RealTimeDataBaseManager.shared.getProfileInfo(safeEmail: email) { result in
                    defer {
                        dispatchGroup.leave()
                    }
                    switch result {
                    case .success(let friend):
                        users.append(friend)
                    case .failure(let error):
                        print("ошибка получения друга: \(error)")
                    }
                }
            }
            dispatchGroup.notify(queue: .main) {
                let selfEmail = UserDefaults.standard.string(forKey: "safeEmail") ?? ""
                let emailsFriend = self.generalFriends?.compactMap { $0.safeEmail }
                for user in users {
                    if emailsFriend?.contains(user.safeEmail) != true, let friends = user.friends {
                        var friend = user
                        friend.friends?.append(selfEmail)
                        self.generalFriends?.append(friend)
                    } else if  emailsFriend?.contains(user.safeEmail) != true {
                        var friend = user
                        friend.friends = [ selfEmail ]
                        self.generalFriends?.append(friend)
                    }
                }

            }

        }
    }


    func setupLocationObserver() {
        guard let friends = self.generalFriends else {
            return
        }
        for friend in friends {
            let friendLocationRef = database.child(friend.safeEmail).child("location")
            if locationObservers[friend.safeEmail] == nil {
                let handle = friendLocationRef.observe(.value) { snapshot in
                    guard let locationDict = snapshot.value as? [String: Any],
                          let latitude = locationDict["latitude"] as? Double,
                          let longitude = locationDict["longitude"] as? Double else {
                        print("gg")
                        return
                    }
                    let location = ["latitude": latitude, "longitude": longitude]
                    let updateUser = User(name: friend.name, email: friend.email, profilePicture: friend.profilePicture, location: location)
                    self.userLocationUpdate = updateUser
                }
                locationObservers[friend.safeEmail] = handle

            }

        }
    }


    func addLocationObserver(user: User) {
        let friendLocationRef = database.child(user.safeEmail).child("location")
        let handle = friendLocationRef.observe(.value) { snapshot in
            guard let locationDict = snapshot.value as? [String: Any],
                  let latitude = locationDict["latitude"] as? Double,
                  let longitude = locationDict["longitude"] as? Double else {
                print("gg")
                return
            }
            let location = ["latitude": latitude, "longitude": longitude]
            let updateUser = User(name: user.name, email: user.email, profilePicture: user.profilePicture, location: location)
            self.userLocationUpdate = updateUser
        }
        locationObservers[user.safeEmail] = handle
    }


    func removeLocationObserver(user: User) {
        guard let handle = locationObservers[user.safeEmail] else {
            print("нет такого обсервера: \(user.safeEmail)")
            return
        }
        let friendLocationRef = database.child(user.safeEmail).child("location")
        friendLocationRef.removeObserver(withHandle: handle)
        locationObservers.removeValue(forKey: user.safeEmail)
    }

    func removeAllLocationObservers() {
        for (safeEmail, handle) in locationObservers {
            let friendLocationRef = database.child(safeEmail).child("location")
            friendLocationRef.removeObserver(withHandle: handle)
        }
        locationObservers.removeAll()
    }

}




//            if generalFriends?.count ?? 0 > emails.count {
//                let friendsEmails = generalFriends?.compactMap { $0.safeEmail }
//                let deleteEmails = emails.filter { email in
//                    friendsEmails?.contains(email) == true
//                }
//                print(emails)
//
//            }
//            print(generalFriends?.count)
//            print(emails.count)
//            print("\(emails) +  fkmdslfmlksdmfklsdmflkdsmlkfmldskfmlksdmf")
//            print(emails)
//            if generalFriends?.count ?? 0 > emails.count, let friendsEmails = generalFriends?.compactMap({ $0.safeEmail }) {
//                let emailsSet = Set(emails)
//                let remainingFriends = generalFriends?.filter { friend in
//                    !emailsSet.contains(friend.safeEmail)
//                }
//                generalFriends = remainingFriends
//                return
//            }
