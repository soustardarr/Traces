//
//  NewChatViewModel.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 07.05.2024.
//

import Foundation
import Combine

class NewChatViewModel: ObservableObject {

    @Published var friends: [User]?
    private var cancellable: Set<AnyCancellable> = []
    var arrayPhrases: [String] = []

    init() {
        self.obtainPhrases()
        FriendsLocationAndChatManager.shared.$generalFriends.receive(on: DispatchQueue.main).sink { [weak self] users in
            if let users = users {
                self?.friends = users
            } else {
                self?.obtainFriends()
            }
        }.store(in: &cancellable)
    }

    func obtainFriends() {
        FriendsLocationAndChatManager.shared.obtainEmails()
        FriendsLocationAndChatManager.shared.$generalFriends.receive(on: DispatchQueue.main).sink { [ weak self ]  users in
            if let users = users {
                self?.friends = users
            }
        }.store(in: &cancellable)
    }

    func obtainPhrases() {
        let path = "/Users/ruslankozlov/git/RerositoryTraces/Traces/TracesApp/TracesApp/Supporting Files/phrases.txt"
        do {
            let fileContents = try String(contentsOfFile: path, encoding: .utf8)
            let lines = fileContents.components(separatedBy: .newlines)
            for line in lines {
                arrayPhrases.append(line)
            }
        } catch {
            print("Ошибка чтения файла: \(error)")
        }
    }

}
