//
//  UserEntity+CoreDataProperties.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 20.05.2024.
//
//

import Foundation
import CoreData


extension UserEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserEntity> {
        return NSFetchRequest<UserEntity>(entityName: "UserEntity")
    }

    @NSManaged public var name: String?
    @NSManaged public var id: String?
    @NSManaged public var safeEmail: String?
    @NSManaged public var email: String?
    @NSManaged public var profilePictureFileName: String?
    @NSManaged public var profilePicture: Data?
    @NSManaged public var lastMessage: LastMessageEntity?

}

extension UserEntity : Identifiable {

}
