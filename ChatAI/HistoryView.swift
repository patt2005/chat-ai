//
//  HistoryView.swift
//  ChatAI
//
//  Created by Petru Grigor on 26.12.2024.
//

import SwiftUI

struct HistoryView: View {
    private func getAssistantInfo(type: AssistantModelType) -> AssistantModel {
        switch type {
        case .openAi: return AssistantModel(name: "ChatGPT", avatar: "chatgpt", apiModel: OpenAiApi.shared, type: .openAi)
        case .claudeAi: return AssistantModel(name: "Claude AI", avatar: "claude", apiModel: ClaudeAiApi.shared, type: .claudeAi)
        case .gemini: return AssistantModel(name: "Gemini", avatar: "gemini", apiModel: GeminiAiApi.shared, type: .gemini)
        case .metaAi: return AssistantModel(name: "Meta AI", avatar: "meta", apiModel: MetaAiApi.shared, type: .metaAi)
        case .qwen: return AssistantModel(name: "Qwen", avatar: "qwen", apiModel: QwenApi.shared, type: .qwen)
        }
    }
    
    struct ChatHistoryCard: View {
        struct AssistantInfo {
            let name: String
            let avatar: String
        }
        
        let history: ChatHistoryEntity
        let info: AssistantModel
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(info.avatar)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .cornerRadius(25)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(info.name)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("Messages: \(history.messages.count)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                
                Divider()
                    .background(Color.gray)
                
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(history.messages.suffix(2).reversed()) { message in
                        Text(message.sendText)
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }
                }
            }
            .padding()
            .background(
                LinearGradient(colors: [Color.blue.opacity(0.2), AppConstants.shared.primaryColor.opacity(0.5)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .cornerRadius(15)
            .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 5)
        }
    }
    
    @ObservedObject private var appProvider = AppProvider.shared
    
    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    init() {
        impactFeedback.prepare()
    }
    
    var body: some View {
        if appProvider.chatHistory.isEmpty {
            VStack(spacing: 30) {
                ZStack {
                    Circle()
                        .frame(width: 90, height: 90)
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [.gray.opacity(0.2), .gray.opacity(0.1)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 5)
                        .scaleEffect(1.05)
                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: true)
                    
                    Image(systemName: "tray.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.gray)
                }
                
                VStack(spacing: 12) {
                    Text("No Chat History")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Start a conversation to see your chat history here.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 40)
                }
                
                Button(action: {
                    impactFeedback.impactOccurred()
                    appProvider.navigationPath.append(.chatView())
                }) {
                    HStack {
                        Image(systemName: "plus")
                            .fontWeight(.bold)
                        Text("Start New")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 15)
                    .padding(.horizontal, 25)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.green, .green.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: .green.opacity(0.5), radius: 8, x: 0, y: 5)
                    )
                    .padding(.bottom, 60)
                }
                .scaleEffect(1.05)
                .animation(.easeInOut(duration: 0.3), value: true)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppConstants.shared.backgroundColor)
        } else {
            ScrollView {
                LazyVStack(spacing: 15) {
                    ForEach(appProvider.chatHistory.reversed()) { history in
                        let info = getAssistantInfo(type: history.assistantModelType)
                        Button(action: {
                            impactFeedback.impactOccurred()
                            appProvider.navigationPath.append(.chatView(model: info, history: history))
                        }) {
                            ChatHistoryCard(history: history, info: info)
                        }
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppConstants.shared.backgroundColor)
            .preferredColorScheme(.dark)
        }
    }
}
