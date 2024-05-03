//
//  LocationManager.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 02.05.2024.
//

import Foundation
import FirebaseDatabase

enum LocationManagerError: Error {
    case failedReceivingFriendsEmails
}

class FirebaseLocationManager {

    let database = Database.database().reference()

    let serialQueue = DispatchQueue(label: "Firebase.LocationManager.SerialQueue")

    var friendsEmail: [String]? {
        didSet{
            serialQueue.async {
                self.obtainFriends(emails: self.friendsEmail ?? [])
            }
        }
    }

    var friends: [User]? {
        didSet {
            serialQueue.async {
                self.setupObserver()
            }
        }
    }

    var userLocationUpdate: User? {
        didSet {
            locationUpdateForActiveUser?(userLocationUpdate ?? User(name: "", email: ""))
            print("\(userLocationUpdate?.location) \(userLocationUpdate?.name)")
        }
    }

    var locationUpdateForActiveUser: ((User) -> ())?

    init() {
        self.obtainEmails()
    }


    func obtainEmails() {
        serialQueue.async {
            RealTimeDataBaseManager.shared.getEmailFriends { result in
                print("\(Thread.current) obtainEmails")
                switch result {
                case .success(let emails):
                    self.friendsEmail = emails
                case .failure(let error):
                    print("не удалось получить емайлы друзей, error: \(error)")
                }
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
            self.friends = users
        }
    }

    func setupObserver() {
        guard let friends = self.friends else {
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


