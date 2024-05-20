//
//  LastMessageEntity+CoreDataProperties.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 20.05.2024.
//
//

import Foundation
import CoreData


extension LastMessageEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LastMessageEntity> {
        return NSFetchRequest<LastMessageEntity>(entityName: "LastMessageEntity")
    }

    @NSManaged public var id: String?
    @NSManaged public var documentId: String?
    @NSManaged public var fromUserEmail: String?
    @NSManaged public var toUserEmail: String?
    @NSManaged public var text: String?
    @NSManaged public var timestamp: Date?
    @NSManaged public var user: UserEntity?

}

extension LastMessageEntity : Identifiable {

}
