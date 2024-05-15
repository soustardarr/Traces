//
//  LogChatSUIView.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 08.05.2024.
//

import SwiftUI

struct LogChatSUIView: View {

    let user: User
    @ObservedObject var viewModel: LogChatViewModel

    init(user: User) {
        self.user = user
        self.viewModel = LogChatViewModel(user: user)
    }

    var body: some View {
        VStack {
            ZStack {
                messageView
                Text(viewModel.errorMessage)
            }
            bottomTextFielBar
        }
        .navigationTitle(user.name)
        .navigationBarTitleDisplayMode(.inline)
    }


    private var messageView: some View {
        ScrollView {
            ScrollViewReader { proxy in
                VStack {
                    ForEach(viewModel.messages) { message in
                        MessagesView(message: message)
                    }
                    HStack { Spacer() }
                        .id("Empty")
                }
                .id("Empty")
                .onReceive(viewModel.$count, perform: { _ in
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo("Empty", anchor: .bottom)
                    }
                })
            }
        }
        .background(Color(.init(white: 0.8, alpha: 1)))
    }

    private var bottomTextFielBar: some View {
        HStack(spacing: 20) {
            Image(systemName: "plus")
                .resizable()
                .foregroundStyle(.gray)
                .frame(width: 20, height: 20)

            ZStack(alignment: .leading) {
                Text("Сообщение")
                    .foregroundStyle(.gray)
                    .padding(.leading, 5)
                TextEditor(text: $viewModel.textField)
                    .frame(height: 20)
                    .opacity(viewModel.textField.isEmpty ? 0.5 : 1)
                    .autocorrectionDisabled()
            }
            Button {
                viewModel.handleSendMessages()
            } label: {
                Image(systemName: "paperplane.circle")
                    .resizable()
                    .foregroundStyle(.gray)
                    .frame(width: 30, height: 30)
            }

        }.padding(.horizontal)
            .padding(.vertical, 4)

    }
}

struct MessagesView: View {

    let message: Message
    let selfSafeEmail: String
    init(message: Message) {
        self.message = message
        let email = UserDefaults.standard.string(forKey: "email")
        self.selfSafeEmail = RealTimeDataBaseManager.safeEmail(emailAddress: email ?? "")
    }
    var body: some View {
        VStack {
            if message.fromUserEmail == selfSafeEmail {
                HStack {
                    Spacer()
                    HStack {
                        Text(message.text)
                            .foregroundStyle(.white)
                    }
                    .padding()
                    .background(Color.indigo)
                    .clipShape(.rect(cornerRadius: 10))
                }
            } else {
                HStack {
                    HStack {
                        Text(message.text)
                            .foregroundStyle(.black)
                    }
                    .padding()
                    .background(Color.gray)
                    .clipShape(.rect(cornerRadius: 10))
                    Spacer()
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 4)
    }
}


#Preview {
    NavigationView {
        LogChatSUIView(user: User(name: "Yarik", email: "yarik@mail.ru", profilePicture: UIImage.profileIcon.pngData()))
    }
}
