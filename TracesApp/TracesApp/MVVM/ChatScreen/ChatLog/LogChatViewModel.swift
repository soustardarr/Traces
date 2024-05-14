//
//  LogChatViewModel.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 14.05.2024.
//

import Foundation
import Firebase

class LogChatViewModel: ObservableObject {

    @Published var textField = ""
    @Published var errorMessage = ""
    @Published var messages: [Message] = []
    @Published var count = 0

    let user: User?

    init(user: User) {
        self.user = user
        fetchMessages()
    }

    private func fetchMessages() {
        guard let email = UserDefaults.standard.string(forKey: "email") else { return }
        let fromUserEmail = RealTimeDataBaseManager.safeEmail(emailAddress: email)
        guard let toUserEmail = user?.safeEmail else { return }

        FirestoreManager.shared.firestore
            .collection("messages")
            .document(fromUserEmail)
            .collection(toUserEmail)
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "не удалось получить сообщения \(error)"
                    print(error)
                    return
                }

                querySnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        let data = change.document.data()
                        self.messages.append(.init(documentId: change.document.documentID, data: data))
                    }
                })
                DispatchQueue.main.async {
                    self.count += 1
                }
            }
    }

    func handleSendMessages() {
        guard let email = UserDefaults.standard.string(forKey: "email") else { return }
        let fromUserEmail = RealTimeDataBaseManager.safeEmail(emailAddress: email)

        guard let toUserEmail = user?.safeEmail else { return }

        let document = FirestoreManager.shared.firestore
            .collection("messages")
            .document(fromUserEmail)
            .collection(toUserEmail)
            .document()

        let messageData = [ FirebaseConstants.fromUserEmail: fromUserEmail, FirebaseConstants.toUserEmail: toUserEmail, FirebaseConstants.text: textField, "timestamp": Timestamp() ] as [String : Any]
        document.setData(messageData) { error in
            if let error = error {
                self.errorMessage = "ошибка сохранения сообщения firestore: \(error)"
            }
            self.textField = ""
            self.count += 1
        }
        
        let recipientMessageDocument = FirestoreManager.shared.firestore
            .collection("messages")
            .document(toUserEmail)
            .collection(fromUserEmail)
            .document()

        recipientMessageDocument.setData(messageData) { error in
            if let error = error {
                self.errorMessage = "ошибка сохранения сообщения firestore: \(error)"
            }
        }



    }
}
