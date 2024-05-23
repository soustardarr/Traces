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

    let serialQueue = DispatchQueue(label: "Firebase.LocationManager.SerialQueue")

    var locationObservers: [String: DatabaseHandle] = [:]

//    private init() {
//        self.obtainEmails()
//    }

//    func map() {
//        self.obtainEmails()
//    }

    var friendsEmail: [String]? {
        didSet{
            serialQueue.async {
                self.obtainFriends(emails: self.friendsEmail ?? [])
            }
        }
    }

    @Published var generalFriends: [User]? {
        didSet {
            print("\(generalFriends)!!!!!!!!!!!!!!!!")
            setupLocationObserver()
        }
    }

    var userLocationUpdate: User? {
        didSet {
            locationUpdateForActiveUser?(userLocationUpdate ?? User(name: "", email: ""))
            print("\(userLocationUpdate?.location) \(userLocationUpdate?.name)")
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
//            let handle = friendLocationRef.observe(.value) { snapshot in
//                guard let locationDict = snapshot.value as? [String: Any],
//                      let latitude = locationDict["latitude"] as? Double,
//                      let longitude = locationDict["longitude"] as? Double else {
//                    print("gg")
//                    return
//                }
//                let location = ["latitude": latitude, "longitude": longitude]
//                let updateUser = User(name: friend.name, email: friend.email, profilePicture: friend.profilePicture, location: location)
//                self.userLocationUpdate = updateUser
//            }
//            locationObservers[friend.safeEmail] = handle
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


