//
//  ChatViewModel.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 07.05.2024.
//

import Foundation
import Combine

class ChatViewModel: ObservableObject {


    @Published var friends: [User]?

    private var cancellable: Set<AnyCancellable> = []

    init() {
        ObtainFriendManager.shared.$generalFriends.receive(on: DispatchQueue.main).sink { [weak self] users in
            if let users = users {
//                let setUsers = Set(users)
//                if users.count > self?.friends?.count ?? 0 {
//                    if let friends = self?.friends {
//                        let setFriends = Set(friends)
//                        let newFriends = setUsers.subtracting(setFriends)
//
//                        self?.friends?.append(contentsOf: newFriends)
//                    } else {
//                        self?.friends = Array(setUsers)
//                    }
//                } else if users.count < self?.friends?.count ?? 0 {
//                    let setUsers = Set(users)
//                        if var friends = self?.friends {
//                            let setFriends = Set(friends)
//                            let friendsToRemove = setFriends.subtracting(setUsers)
//                            friends.removeAll(where: { friendsToRemove.contains($0) })
//                            self?.friends = friends
//                        }
//                }
                self?.friends = users
                self?.fetchLastMessage()
            } else {
                //self?.obtainFriends()
                //отобрази hud или марку "нет друзей" в завсисмости от статуса
            }
        }.store(in: &cancellable)
    }

    private func fetchLastMessage() {
        guard let selfSafeEmail = UserDefaults.standard.string(forKey: "safeEmail") else { return }
        FirestoreManager.shared.firestore
            .collection("last_messages")
            .document(selfSafeEmail)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("не удалось получить послденее сообщение: \(error)")
                    return
                }
                querySnapshot?.documentChanges.forEach({ change in
                    let lastMessage = LastMessage(documentId: change.document.documentID, data: change.document.data())
                    if let index = self.friends?.firstIndex(where: { $0.safeEmail == lastMessage.toUserEmail }) {
                        self.friends?[index].lastMessage = lastMessage
                        let friend = self.friends?.remove(at: index)
                        self.friends?.insert(friend ?? User(name: "", email: ""), at: 0)
                    } else if let index = self.friends?.firstIndex(where: { $0.safeEmail == lastMessage.fromUserEmail }) {
                        self.friends?[index].lastMessage = lastMessage
                        let friend = self.friends?.remove(at: index)
                        self.friends?.insert(friend ?? User(name: "", email: ""), at: 0)
                    }
                })

            }
    }

}
