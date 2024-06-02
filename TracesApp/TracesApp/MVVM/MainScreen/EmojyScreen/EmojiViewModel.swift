//
//  EmojiViewModel.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 02.06.2024.
//

import Foundation
import AVFoundation
import Firebase

class EmojiViewModel {

    var player: AVAudioPlayer?


    func handleSendMessages(toUserEmail: String, text: String) {
        guard let fromUserEmail = UserDefaults.standard.string(forKey: "safeEmail") else { return }

        let document = FirestoreManager.shared.firestore
            .collection("messages")
            .document(fromUserEmail)
            .collection(toUserEmail)
            .document()

        let messageData = [ FirebaseConstants.fromUserEmail: fromUserEmail, FirebaseConstants.toUserEmail: toUserEmail, FirebaseConstants.text: text, "timestamp": Timestamp() ] as [String : Any]
        document.setData(messageData) { error in
            if let error = error {
                print(error)
            }

            self.safeLastMessage(toEmail: toUserEmail, text: text)
        }

        let recipientMessageDocument = FirestoreManager.shared.firestore
            .collection("messages")
            .document(toUserEmail)
            .collection(fromUserEmail)
            .document()

        recipientMessageDocument.setData(messageData) { error in
            if let error = error {
                print(error)
            }
        }
    }


    private func safeLastMessage(toEmail: String, text: String) {

        guard let fromEmail = UserDefaults.standard.string(forKey: "safeEmail") else { return }

        let document = FirestoreManager.shared.firestore
            .collection("last_messages")
            .document(fromEmail)
            .collection("messages")
            .document(toEmail)

        let data = [FirebaseConstants.timestamp: Timestamp(), FirebaseConstants.text: text, FirebaseConstants.fromUserEmail: fromEmail, FirebaseConstants.toUserEmail: toEmail ] as [String: Any]

        document.setData(data) { error in
            if let error = error {
                print("не удалось сохранить last_messaage: \(error)")
                return
            }
        }

        let documentForInterlocutor = FirestoreManager.shared.firestore
            .collection("last_messages")
            .document(toEmail)
            .collection("messages")
            .document(fromEmail)

        documentForInterlocutor.setData(data) { error in
            if let error = error {
                print("не удалось сохранить last_messaage: \(error)")
                return
            }
        }

    }



    func playHappy() {
        guard let url = Bundle.main.url(forResource: "smeh", withExtension: "mp3") else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("\(error.localizedDescription)")
        }

    }

    func playAngry() {
        guard let url = Bundle.main.url(forResource: "zlo", withExtension: "mp3") else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("\(error.localizedDescription)")
        }
    }

}
