//
//  ObtainProfileExtension.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 01.05.2024.
//

import Foundation

extension RealTimeDataBaseManager {

    //MARK: ПОЛУЧЕНИЕ ИНФОРМАЦИИ О СВОЕМ ПРОФИЛЕ
    public func getProfileInfo(safeEmail: String, completionHandler: @escaping (Result<User, Error>) -> ()) {
        self.database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            if let userDict = snapshot.value as? [String: Any],
               let userName = userDict["name"] as? String,
               let userEmail = userDict["email"] as? String {
                StorageManager.shared.downloadAvatarDataSelfProfile(safeEmail) { data in
                    if data != nil {
                        let user = User(name: userName, email: userEmail, profilePicture: data)
                        completionHandler(.success(user))
                    } else {
                        print("получен профиль без фото")
                        let user = User(name: userName, email: userEmail)
                        completionHandler(.success(user))
                    }
                }
            } else {
                completionHandler(.failure(RealTimeDataBaseError.failedProfile))
                print("Неизвестный формат снимка данных")
            }

        }
    }

    //MARK: ПОЛУЧЕНИЕ ВСЕХ ЮЗЕРОВ
    func getAllUsers(completion: @escaping (Result<[User], Error>) -> ()) {
        database.observeSingleEvent(of: .value) { snapshot in
            guard let childrensJson = snapshot.value as? [String: Any] else {
                completion(.failure(RealTimeDataBaseError.failedReceivingUsers))
                return
            }
            var users: [User] = []
            for (_, value) in childrensJson {
                if let userDict = value as? [String: Any] {
                    let name = userDict["name"] as? String
                    let email = userDict["email"] as? String
                    let friends = userDict["friends"] as? [String]
                    let followers = userDict["followers"] as? [String]
                    let subscriptions = userDict["subscriptions"] as? [String]
                    let user = User(name: name ?? "", email: email ?? "",
                                                friends: friends, followers: followers, subscriptions: subscriptions)
                    users.append(user)
                }
            }
            completion(.success(users))
        }
    }





}
