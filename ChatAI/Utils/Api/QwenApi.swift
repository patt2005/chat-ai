//
//  QwenApi.swift
//  ChatAI
//
//  Created by Petru Grigor on 29.01.2025.
//

import Foundation

class QwenApi: AiModel {
    var modelsList: [String: String] = [:]
    
    static var shared: any AiModel = QwenApi()
    
    struct CompletionResponse: Decodable {
        struct Choice: Decodable {
            let delta: Delta
        }
        
        struct Delta: Decodable {
            let content: String
        }
        
        let choices: [Choice]
    }
    
    func cleanResponseText(_ text: String) -> String {
        var cleanedText = text
        
        cleanedText = cleanedText.replacingOccurrences(of: "\\*\\*(.*?)\\*\\*", with: "$1", options: .regularExpression)
        cleanedText = cleanedText.replacingOccurrences(of: "\\*(.*?)\\*", with: "$1", options: .regularExpression)
        
        cleanedText = cleanedText.replacingOccurrences(of: "####\\s*", with: "", options: .regularExpression)
        cleanedText = cleanedText.replacingOccurrences(of: "###\\s*", with: "", options: .regularExpression)
        cleanedText = cleanedText.replacingOccurrences(of: "##\\s*", with: "", options: .regularExpression)
        cleanedText = cleanedText.replacingOccurrences(of: "#\\s*", with: "", options: .regularExpression)
        
        cleanedText = cleanedText.replacingOccurrences(of: "(?m)^-\\s", with: "• ", options: .regularExpression)
        
        cleanedText = cleanedText.replacingOccurrences(of: "\n{2,}", with: "\n", options: .regularExpression)
        
        return cleanedText
    }
    
    func getChatResponse(_ message: String, imagesList: [String], chatHistoryList: [MessageRow], aiModel: String) async throws -> AsyncThrowingStream<String, Error> {
        let url = URL(string: "https://api.codbun.com/api/qwen/chat")!
        
        let headers = [
            "Content-Type": "application/json",
        ]
        
        var messages: [[String: Any]] = []
        
        chatHistoryList.forEach { chatHistory in
            messages.append([
                "role": "user",
                "content": [["type": "text", "text": chatHistory.sendText]]
            ])
            messages.append([
                "role": "assistant",
                "content": [["type": "text", "text": chatHistory.responseText ?? ""]]
            ])
        }
        
        var userMessageContent: [[String: Any]] = []
        
        imagesList.forEach { image in
            userMessageContent.insert(["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(image)"]], at: 0)
        }
        
        userMessageContent.append(["type": "text", "text": message])
        
        messages.append([
            "role": "user",
            "content": userMessageContent,
        ])
        
        let requestBody: [String: Any] = [
            "model": aiModel,
            "messages": messages,
            "stream": true,
        ]
        
        var request = URLRequest(url: url)
        
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        request.httpMethod = "POST"
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else {
            print("Error: Unable to serialize JSON")
            throw ApiAnalysisError.invalidData
        }
        request.httpBody = jsonData
        
        if !AppProvider.shared.isUserSubscribed && !imagesList.isEmpty {
            return AsyncThrowingStream<String, Error> { continuation in
                continuation.yield("You need a Premium Subscription to upload images. Upgrade now to unlock this feature and enhance your experience!")
                continuation.finish()
            }
        }
        
        let (result, response) = try await URLSession.shared.bytes(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ApiAnalysisError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw ApiAnalysisError.invalidResponse
        }
        
        return AsyncThrowingStream<String, Error> { continuation in
            Task(priority: .userInitiated) {
                do {
                    for try await line in result.lines {
                        if line.hasPrefix("data: "), let data = line.dropFirst(6).data(using: .utf8), let response = try? JSONDecoder().decode(CompletionResponse.self, from: data), let text = response.choices.first?.delta.content {
                            continuation.yield(cleanResponseText(text))
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
