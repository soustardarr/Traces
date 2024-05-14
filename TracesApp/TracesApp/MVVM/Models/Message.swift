//
//  Message.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 14.05.2024.
//

import Foundation

struct Message: Identifiable {
    var id: String { documentId }
    let documentId: String
    let fromUserEmail, toUserEmail, text: String

    init(documentId: String, data: [String: Any]) {
        self.fromUserEmail = data[FirebaseConstants.fromUserEmail] as? String ?? ""
        self.toUserEmail = data[FirebaseConstants.toUserEmail] as? String ?? ""
        self.text = data[FirebaseConstants.text] as? String ?? ""
        self.documentId = documentId
    }
}

struct FirebaseConstants {
    static let fromUserEmail = "fromUserEmail"
    static let toUserEmail = "toUserEmail"
    static let text = "text"
}
