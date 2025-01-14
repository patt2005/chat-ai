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
    
    @Binding var showImageContent: Bool
    @Binding var selectedImage: UIImage?
    
    private func messageBubble(isUser: Bool, text: String, image: String? = nil, responseError: String?, isLoading: Bool, imagesList: [String] = []) -> some View {
        HStack(alignment: .top, spacing: 13) {
            if (!isUser) {
                Image(image!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
                    .cornerRadius(17.5)
            }
            
            VStack(alignment: isUser ? .trailing : .leading) {
                if !imagesList.isEmpty {
                    LazyVStack(alignment: .trailing, spacing: 10) {
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
                }
                
                if let error = responseError {
                    Text("Error: \(error)")
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
