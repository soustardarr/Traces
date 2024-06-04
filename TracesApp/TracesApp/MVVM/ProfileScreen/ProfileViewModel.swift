//
//  ProfileViewModel.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 01.05.2024.
//

import Foundation
import FirebaseAuth

class ProfileViewModel {

    func signOut() {
        UserDefaults.standard.removeObject(forKey: "email")
        UserDefaults.standard.removeObject(forKey: "safeEmail")
        ObtainFriendManager.shared.removeAllLocationObservers()
        ObtainFriendManager.shared.generalFriends?.removeAll()
        ObtainFriendManager.shared.friendsEmails?.removeAll()
        CoreDataManager.shared.deleteAllInfo()
        do {
            try FirebaseAuth.Auth.auth().signOut()
            AppCoordinator.shared.start()
        } catch let error {
            print(error)
        }
    }

}
