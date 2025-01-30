//
//  QwenApi.swift
//  ChatAI
//
//  Created by Petru Grigor on 29.01.2025.
//

import Foundation

class QwenApi: AiModel {
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
    
    func getChatResponse(_ message: String, imagesList: [String], chatHistoryList: [MessageRow]) async throws -> AsyncThrowingStream<String, Error> {
        let url = URL(string: "https://dashscope-intl.aliyuncs.com/compatible-mode/v1/chat/completions")!
        
        let headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(AppConstants.shared.qwenApiKey)"
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
        
        var userMessageContent: [[String: Any]] = [
            ["type": "text", "text": message],
        ]
        
        imagesList.forEach { image in
            userMessageContent.insert(["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(image)"]], at: 0)
        }
        
        messages.append([
            "role": "user",
            "content": userMessageContent,
        ])
        
        let requestBody: [String: Any] = [
            "model": "qwen-vl-max",
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
                            continuation.yield(text.replacingOccurrences(of: "**", with: ""))
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
