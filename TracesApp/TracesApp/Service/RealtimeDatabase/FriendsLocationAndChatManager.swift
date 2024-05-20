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

class FriendsLocationAndChatManager {

    static let shared = FriendsLocationAndChatManager()

    let database = Database.database().reference()

    let serialQueue = DispatchQueue(label: "Firebase.LocationManager.SerialQueue")

    private init() {
        self.obtainEmails()
    }

    var friendsEmail: [String]? {
        didSet{
            serialQueue.async {
                self.obtainFriends(emails: self.friendsEmail ?? [])
            }
        }
    }

    @Published var generalFriends: [User]? {
        didSet {
            self.setupObserver()
        }
    }

    var userLocationUpdate: User? {
        didSet {
            locationUpdateForActiveUser?(userLocationUpdate ?? User(name: "", email: ""))
//            print("\(userLocationUpdate?.location) \(userLocationUpdate?.name)")
        }
    }

    var locationUpdateForActiveUser: ((User) -> ())?



    func obtainEmails() {
        RealTimeDataBaseManager.shared.getEmailFriends { result in
            switch result {
            case .success(let emails):
                self.friendsEmail = emails
            case .failure(let error):
                print("не удалось получить емайлы друзей, error: \(error)")
            }
        }

    }

    func obtainFriends(emails: [String]) {
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
        dispatchGroup.notify(queue: serialQueue) {
            self.generalFriends = users
        }
    }

    func setupObserver() {
        guard let friends = self.generalFriends else {
            return
        }
        for friend in friends {
            let friendLocationRef = database.child(friend.safeEmail).child("location")
            friendLocationRef.observe(.value) { snapshot in
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
        }
    }
}


