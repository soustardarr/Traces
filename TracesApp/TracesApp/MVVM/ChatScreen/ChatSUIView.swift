//
//  ChatSUIView.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 03.05.2024.
//

import SwiftUI

struct ChatSUIView: View {

    @ObservedObject private var viewModel = ChatViewModel()
    @State var isSheetPresented = false

    var customNavBar: some View {
        HStack {
            Text("Сообщения")
                .font(.system(size: 35, weight: .bold))
            Spacer()
            Image(systemName: "square.and.pencil.circle.fill")
                .onTapGesture {
                    isSheetPresented.toggle()
                }
                .font(.system(size: 30))
                .sheet(isPresented: $isSheetPresented, content: {
                    NewChatSUIView()
                })
        }.padding()
    }

    var body: some View {
        NavigationView {
            VStack {
                customNavBar
                messagesView
            }.navigationBarHidden(true)
        }
    }


//MARK: - MessagesView
    var messagesView: some View {
        ScrollView {
            ForEach(0..<20, id: \.self) { _ in
                VStack {
                    HStack(spacing: 20) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .clipShape(Circle())
                        VStack(alignment: .leading) {
                            HStack {
                                Text("User name")
                                    .font(.system(size: 16, weight: .bold))
                                Circle()
                                    .frame(height: 8)
                                    .foregroundStyle(.green)
                            }
                            Text("hello, how are you?")
                                .font(.system(size: 12, weight: .light))
                            Spacer()
                        }
                        Spacer()
                        VStack() {

                            Text("17.00")
                                .font(.system(size: 12, weight: .ultraLight))
                            Spacer()
                            Circle().frame(height: 20)
                                .foregroundStyle(.gray)
                                .overlay {
                                    Text("23")
                                        .font(.system(size: 10))
                                        .foregroundColor(.black)
                                }
                            Spacer()
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
