//
//  RegistrationViewModel.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 01.05.2024.
//

import Foundation
import UIKit
import FirebaseAuth

class RegistrationViewModel {
    func didRegisteredUser(_ name: String?, _ email: String?, _ password: String?, _ secondPassword: String?, _ avatar: UIImage?,
                           completion: @escaping (_ userInfo: User?, _ message: String?) -> ()) {
        guard let name = name, let login = email,
              let password = password, let secondPassword = secondPassword,
              let image = avatar,
              !login.isEmpty,
              !password.isEmpty,
              !secondPassword.isEmpty,
              !name.isEmpty,
              password == secondPassword,
              password.count >= 6,
              name.count >= 3
        else {
            completion(nil, "проверьте правильность введенной информации")
            return
        }
        RealTimeDataBaseManager.shared.userExists(with: login) { exists in
            if exists {
                completion(nil, "пользователь с таким email уже существует")
            } else {
                let user = User(name: name, email: login, profilePicture: image.pngData())
                FirebaseAuth.Auth.auth().createUser(withEmail: login, password: password) { dataResult, error in
                    guard dataResult != nil, error == nil else {
                        completion(nil, "не удалось создать пользователя")
                        return
                    }
                    print("создана учетная запись")
                    completion(user, nil)
                    // Выход из учетной записи
                    do {
                        try FirebaseAuth.Auth.auth().signOut()
                    } catch let signOutError as NSError {
                        print("Ошибка при выходе из учетной записи: \(signOutError.localizedDescription)")
                    }

                }
            }
        }
    }

    func setProfileInDatabase(user: User) {
        RealTimeDataBaseManager.shared.insertUser(with: user) { result in
            if result {
                print("успешная вставка юзера в бд")
            }
        }
    }

    func uploadAvatarImage(user: User) {
        StorageManager.shared.uploadImage(with: user.profilePicture ?? Data(), fileName: user.profilePictureFileName) { result in
            switch result {
            case .success(let downloadUrl):
                UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                print("ссылка на скачивание: \(downloadUrl)")
            case .failure(let error):
                print("ошибка хранилища: \(error)")
            }
        }

    }

}
