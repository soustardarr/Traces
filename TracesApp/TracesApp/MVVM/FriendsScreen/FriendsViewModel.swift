//
//  FriendsViewModel.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 02.05.2024.
//

import Foundation
import Combine
import UIKit


class FriendsViewModel {

    @Published var results: [User]?

    @Published var users = [User]()
    var hasFetched = false

    func searchUsers(text: String) {
        if hasFetched {
            filterUsers(text)
        } else {
            RealTimeDataBaseManager.shared.getAllUsers { [ weak self ] result in
                switch result {
                case .success(let users):
                    self?.hasFetched = true
                    self?.users = users
                    self?.filterUsers(text)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }

    func filterUsers(_ text: String) {
        guard hasFetched else {
            return
        }
        let safeEmail  = UserDefaults.standard.string(forKey: "safeEmail") ?? ""
        var resultUsers: [User] = self.users.filter {
            return $0.name.lowercased().hasPrefix(text.lowercased())
        }
        resultUsers.removeAll(where: { $0.safeEmail == safeEmail})
        guard !resultUsers.isEmpty else {
            return
        }
        self.results = resultUsers
    }


    func getImage(pictureFileName: String, completion: @escaping (Data) -> Void) {
        StorageManager.shared.downloadImage(pictureFileName) { result in
            switch result {
            case.success(let imageData):
                completion(imageData)
            case .failure(let error):
                print("ошибка установки фото \(error)")
                completion(Data())
            }
        }

    }


}


