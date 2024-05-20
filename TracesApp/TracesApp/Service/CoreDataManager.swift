//
//  CoreDataManager.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 20.05.2024.
//

import Foundation
import CoreData

class CoreDataManager {

    static var shared = CoreDataManager()

    private init() { }

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TracesApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()


    func saveContext () {
        let context = viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func saveUsersWithLastMessages(users: [User]) {
        for user in users {
            let fetchRequest = UserEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", user.id)

            do {
                let fetchedResults = try viewContext.fetch(fetchRequest)

                let userEntity: UserEntity
                if let existingUserEntity = fetchedResults.first {
                    userEntity = existingUserEntity
                } else {
                    userEntity = UserEntity(context: viewContext)
                }

                userEntity.id = user.id
                userEntity.name = user.name
                userEntity.email = user.email
                userEntity.safeEmail = user.safeEmail
                userEntity.profilePictureFileName = user.profilePictureFileName
                userEntity.profilePicture = user.profilePicture

                let lastMessageEntity: LastMessageEntity
                if let lastMessage = user.lastMessage {
                    let messageFetchRequest = LastMessageEntity.fetchRequest()
                    messageFetchRequest.predicate = NSPredicate(format: "id == %@", lastMessage.id)

                    let fetchedMessages = try viewContext.fetch(messageFetchRequest)

                    if let existingMessageEntity = fetchedMessages.first {
                        lastMessageEntity = existingMessageEntity
                    } else {
                        lastMessageEntity = LastMessageEntity(context: viewContext)
                    }

                    lastMessageEntity.id = lastMessage.id
                    lastMessageEntity.documentId = lastMessage.documentId
                    lastMessageEntity.fromUserEmail = lastMessage.fromUserEmail
                    lastMessageEntity.toUserEmail = lastMessage.toUserEmail
                    lastMessageEntity.text = lastMessage.text
                    lastMessageEntity.timestamp = lastMessage.timestamp
                    lastMessageEntity.user = userEntity
                    userEntity.lastMessage = lastMessageEntity
                } else {
                    userEntity.lastMessage = nil
                }
            } catch {
                print("Ошибка кеширования: \(error)")
            }
        }
        saveContext()
    }



    func obtainUsersWithLastMessages() -> [User]? {

        var obtainedUsers: [User] = []

        let fetchRequest = UserEntity.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "lastMessage.timestamp", ascending: false)
        fetchRequest.sortDescriptors = [ sortDescriptor ]
        do {
            let users = try viewContext.fetch(fetchRequest)
            for userEntity in users {
                let lastMessage = LastMessage(documentId: userEntity.lastMessage?.documentId ?? "", fromUserEmail: userEntity.lastMessage?.fromUserEmail ?? "", toUserEmail: userEntity.lastMessage?.toUserEmail ?? "", text: userEntity.lastMessage?.text ?? "", timestamp: userEntity.lastMessage?.timestamp ?? Date() + 3)
                let user = User(name: userEntity.name ?? "",
                                email: userEntity.email ?? "",
                                profilePicture: userEntity.profilePicture,
                                lastMessage: lastMessage)
                obtainedUsers.append(user)
            }
        } catch {
            print("ошибка получения всех пользователей в chatView \(error)")
            return nil
        }
        print(obtainedUsers)
        return obtainedUsers
    }

}
