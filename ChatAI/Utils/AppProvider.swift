//
//  AppProvider.swift
//  ChatAI
//
//  Created by Petru Grigor on 26.12.2024.
//

import Foundation
import SwiftUI
import RevenueCat
import FirebaseAnalytics

class ChatHistoryEntity: Identifiable, Hashable, Equatable, Codable {
    static func == (lhs: ChatHistoryEntity, rhs: ChatHistoryEntity) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(assistantModelType)
        hasher.combine(messages)
    }
    
    let id: UUID
    let assistantModelType: AssistantModelType
    var messages: [MessageRow]
    
    init(id: UUID, assistantModelType: AssistantModelType, messages: [MessageRow]) {
        self.id = id
        self.assistantModelType = assistantModelType
        self.messages = messages
    }
}

class AppProvider: ObservableObject {
    static let shared = AppProvider()
    
    @Published var navigationPath: [NavigationDestination] = []
    
    @Published var chatHistory: [ChatHistoryEntity] = []
    
    @Published var isFirstOpen = false
    @Published var isUserSubscribed = false
    
    @Published var messagesCount: Int = 0
    
    private let userDefaults = UserDefaults.standard
    
    private let messageCountKey = "dailyMessageCount"
    private let lastResetKey = "lastResetDate"
    private let maxDailyMessages = 10
    
    private func loadMessagesCount() {
        let lastResetDate = userDefaults.object(forKey: lastResetKey) as? Date ?? Date.distantPast
        
        if !Calendar.current.isDateInToday(lastResetDate) {
            resetDailyMessages()
        } else {
            messagesCount = userDefaults.integer(forKey: messageCountKey)
        }
    }
    
    func sendMessage() {
        guard messagesCount > 0 else { return }
        
        messagesCount -= 1
        userDefaults.set(messagesCount, forKey: messageCountKey)
    }
    
    private func resetDailyMessages() {
        messagesCount = maxDailyMessages
        userDefaults.set(messagesCount, forKey: messageCountKey)
        userDefaults.set(Date(), forKey: lastResetKey)
    }
    
    private init() {
        self.isFirstOpen = !UserDefaults.standard.bool(forKey: "hasOpenedAppBefore")
        loadMessagesCount()
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            self.isUserSubscribed = customerInfo?.entitlements.all["pro"]?.isActive == true
        }
        AnalyticsManager.shared.setUserProperty(value: self.isUserSubscribed.description, property: "isPremiumUser")
        loadChatHistory()
    }
    
    func completeOnboarding() {
        AnalyticsManager.shared.logEvent(name: AnalyticsEventTutorialComplete)
        UserDefaults.standard.set(true, forKey: "hasOpenedAppBefore")
        DispatchQueue.main.async {
            self.isFirstOpen = false
        }
    }
    
    func saveChatHistory() {
        do {
            let data = try JSONEncoder().encode(chatHistory)
            UserDefaults.standard.set(data, forKey: "chatHistoryKey")
        } catch {
            print("Error saving chat history: \(error.localizedDescription)")
        }
    }
    
    private func loadChatHistory() {
        guard let data = UserDefaults.standard.data(forKey: "chatHistoryKey") else { return }
        do {
            chatHistory = try JSONDecoder().decode([ChatHistoryEntity].self, from: data)
        } catch {
            print("Error loading chat history: \(error.localizedDescription)")
        }
    }
}
