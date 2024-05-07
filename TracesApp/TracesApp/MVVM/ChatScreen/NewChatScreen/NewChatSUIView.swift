//
//  NewChatSUIView.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 07.05.2024.
//

import SwiftUI

struct NewChatSUIView: View {

    @Environment(\.dismiss) var dismiss
    @ObservedObject private var viewModel = NewChatViewModel()
    var body: some View {
        NavigationView(content: {
            ScrollView {
                ForEach(viewModel.friends ?? []) { user in
                    Button {
                        dismiss()
                    } label: {
                        if let uiImage = UIImage(data: user.profilePicture!) {
                            HStack(spacing: 20) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(user.name)
                                        .foregroundStyle(.black)
                                    Text(viewModel.arrayPhrases.randomElement() ?? "")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(.black)
                                }
                                Spacer()
                            }.padding()
                        }
                    }
                    Divider()
                }

            }.navigationTitle("Пора пообщаться!")
        })
    }
}

#Preview {
    NewChatSUIView()
}
