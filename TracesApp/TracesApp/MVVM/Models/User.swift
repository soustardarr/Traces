//
//  User.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 01.05.2024.
//

import Foundation

struct User: Identifiable, Hashable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.safeEmail == rhs.safeEmail
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(safeEmail)
    }
    
    var id: String { safeEmail }
    var name: String
    var email: String
    var safeEmail: String {
        let safeEmail = email.replacingOccurrences(of: ".", with: ",")
        return safeEmail
    }
    var profilePictureFileName: String {
        return "\(safeEmail)_profile_picture.png"
    }
    var profilePicture: Data?
    var friends: [String]?
    var followers: [String]?
    var subscriptions: [String]?
    var location: [String: Double]?
    var lastMessage: LastMessage?
}
