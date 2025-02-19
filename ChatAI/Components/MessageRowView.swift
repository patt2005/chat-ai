//
//  MessageRowView.swift
//  ChatAI
//
//  Created by Petru Grigor on 27.12.2024.
//

import SwiftUI

struct AssistantModel: Hashable, Equatable {
    static func == (lhs: AssistantModel, rhs: AssistantModel) -> Bool {
        return lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(avatar)
    }
    
    let name: String
    let avatar: String
    let apiModel: AiModel
    let type: AssistantModelType
}

struct MessageRow: Identifiable, Hashable, Equatable, Codable {
    static func == (lhs: MessageRow, rhs: MessageRow) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(responseText)
    }
    
    var id = UUID()
    var isInteracting: Bool
    let sendText: String
    let responseImage: String
    var responseText: String?
    var responseError: String?
    let uploadedImages: [String]
}

struct MessageRowView: View {
    let messageRow: MessageRow
    let retryCallback: (MessageRow) -> Void
    
    @State private var isCopied = false
    
    @Binding var showImageContent: Bool
    @Binding var selectedImage: UIImage?
    
    @ObservedObject private var appProvider = AppProvider.shared
    
    private func messageBubble(isUser: Bool, text: String, image: String? = nil, responseError: String?, isLoading: Bool, imagesList: [String] = []) -> some View {
        HStack(alignment: .top, spacing: 13) {
            if (!isUser) {
                Image(image!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
                    .cornerRadius(17.5)
            }
            
            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                if !imagesList.isEmpty {
                    ReversedScrollView {
                        ForEach(Array(imagesList.enumerated()), id: \.offset) { index, image in
                            if let imageData = Data(base64Encoded: image), let image = UIImage(data: imageData) {
                                Button(action: {
                                    selectedImage = image
                                    showImageContent = true
                                }) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(8)
                                        .clipped()
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
                }
                
                if !text.isEmpty {
                    HStack(alignment: .top, spacing: 0) {
                        if isUser {
                            Spacer()
                        }
                        
                        Text(text)
                            .multilineTextAlignment(.leading)
                            .textSelection(.enabled)
                            .padding(isUser ? 12 : 0)
                            .background(isUser ? AppConstants.shared.grayColor : AppConstants.shared.backgroundColor)
                            .cornerRadius(isUser ? 16 : 0)
                    }
                    
                    if !isUser {
                        HStack(spacing: 15) {
                            Button(action: {
                                UIPasteboard.general.string = text
                                withAnimation {
                                    isCopied = true
                                }
                                
                                let generator = UINotificationFeedbackGenerator()
                                generator.notificationOccurred(.success)
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        isCopied = false
                                    }
                                }
                            }) {
                                Image(systemName: isCopied ? "checkmark" : "doc.on.doc.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 18, height: 18)
                                .padding(8)
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.borderless)
                            
                            Button(action: {
                                appProvider.stringToShare = text
                                appProvider.isSharing = true
                                
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                            }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 18, height: 18)
                                }
                                .padding(8)
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.borderless)
                        }
                        .padding(.top, 5)
                    }
                }
                
                if responseError != nil {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Something went wrong. Please try again.")
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.leading)
                        
                        Button(action: {
                            retryCallback(messageRow)
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundStyle(.white)
                                    .frame(width: 16, height: 16)
                                
                                Text("Try again")
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                }
                
                if isLoading {
                    LoadingAnimation()
                        .frame(width: 60, height: 30)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            messageBubble(isUser: true, text: messageRow.sendText, responseError: nil, isLoading: false, imagesList: messageRow.uploadedImages)
            
            if let message = messageRow.responseText {
                messageBubble(isUser: false, text: message, image: messageRow.responseImage, responseError: messageRow.responseError, isLoading: messageRow.isInteracting)
            }
        }
    }
}
