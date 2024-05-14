//
//  RealTimeDataBaseManager.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 01.05.2024.
//

import Foundation
import FirebaseDatabase
import UIKit

enum RealTimeDataBaseError: Error {
    case failedProfile
    case failedReceivingUsers
    case failedReceivingFriends
    case failedReceivingPublication
}

class RealTimeDataBaseManager {

    static let shared = RealTimeDataBaseManager()

    let database = Database.database().reference()

    @Published var currentUser: User?


    static func safeEmail(emailAddress: String) -> String {
        let safeEmail = emailAddress.replacingOccurrences(of: ".", with: ",")
        return safeEmail
    }

}

