//
//  FirestoreManager.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 14.05.2024.
//

import Foundation
import FirebaseFirestore

class FirestoreManager {

    static var shared = FirestoreManager()

    let firestore = Firestore.firestore()


}
