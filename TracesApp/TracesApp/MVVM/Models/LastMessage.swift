//
//  LastMessage.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 15.05.2024.
//

import Foundation
import Firebase

struct LastMessage: Identifiable {
    var id: String { documentId }
    let documentId: String
    let fromUserEmail, toUserEmail, text: String
    let timestamp: Date
//    let readIt: Bool?
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }

    init(documentId: String, data: [String: Any]) {
        self.documentId = documentId
        self.fromUserEmail = data[FirebaseConstants.fromUserEmail] as? String ?? ""
        self.toUserEmail = data[FirebaseConstants.toUserEmail] as? String ?? ""
        self.text = data[FirebaseConstants.text] as? String ?? ""
        if let timestamp = data[FirebaseConstants.timestamp] as? Timestamp {
            self.timestamp = timestamp.dateValue()
            print("\(self.timestamp) INITINITINTITINTITNITNTNITNIT \(self.text)")
        } else {
            self.timestamp = Date()  // текущая дата по умолчанию
        }
//        self.timestamp = data[FirebaseConstants.timestamp] as? Date ?? Date()
//        self.readIt = data[FirebaseConstants.readIt] as? Bool 
    }

    init(documentId: String, fromUserEmail: String, toUserEmail: String, text: String, timestamp: Date) {
        self.documentId = documentId
        self.fromUserEmail = fromUserEmail
        self.toUserEmail = toUserEmail
        self.text = text
        self.timestamp = timestamp
    }



}

