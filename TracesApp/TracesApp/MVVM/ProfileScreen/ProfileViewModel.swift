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
        do {
            try FirebaseAuth.Auth.auth().signOut()
            AppCoordinator.shared.start()
        } catch let error {
            print(error)
        }
    }

}
