//
//  ChatSUIView.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 03.05.2024.
//

import SwiftUI

struct ChatSUIView: View {

    @ObservedObject private var viewModel = ChatViewModel()
    @State var isPresentedChat = false
    @State var user: User?

    var customNavBar: some View {
        HStack {
            Text("Сообщения")
                .font(.system(size: 35, weight: .bold))
            Spacer()
            Image(systemName: "square.and.pencil.circle.fill")
                .font(.system(size: 30))
        }.padding()
    }
    
    var body: some View {
        NavigationView {

            VStack {
                customNavBar
                messagesView
            }
            .navigationBarHidden(true)
        }
    }

    var messagesView: some View {
        ScrollView {
            ForEach(viewModel.friends) { user in
                VStack {
                    NavigationLink {
                        LogChatSUIView(user: user)
                    } label: {
                        HStack(spacing: 20) {
                            if let uiImage = UIImage(data: user.profilePicture!) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(user.name)
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundStyle(.black)
//                                        Circle()
//                                            .frame(height: 8)
//                                            .foregroundStyle(.green)
                                    }
                                    Text(user.lastMessage?.text ?? "Начните общение!")
                                        .font(.system(size: 12, weight: .light))
                                        .frame(alignment: .leading)
                                        .foregroundStyle(.black)
                                    Spacer()
                                }
                                Spacer()
                                VStack() {
                                    if let readIt = user.lastMessage?.readIt {
                                        if readIt {
                                            Circle().frame(height: 10)
                                                .foregroundStyle(.blue)
                                        }
                                    }
                                }

                            }
                        }
                    }

                    Divider()
                        .padding(.vertical, 8)
                }.padding(.horizontal)
            }
        }
    }

}

#Preview {
    ChatSUIView()
}