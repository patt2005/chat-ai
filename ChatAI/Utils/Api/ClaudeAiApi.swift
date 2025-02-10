//
//  ClaudeAiApi.swift
//  ChatAI
//
//  Created by Petru Grigor on 27.12.2024.
//

import Foundation
import SwiftUI

class ClaudeAiApi: AiModel {
    var modelsList: [String] = ["claude-3-5-sonnet-20241022", "claude-3-5-sonnet-20240620",
                                "claude-3-haiku-20240307", "claude-3-opus-20240229", "claude-3-sonnet-20240229"]
    
    static var shared: any AiModel = ClaudeAiApi()
    
    struct ClaudeRequest: Codable {
        let model: String
        let max_tokens: Int
        let temperature: Double
        let system: String
        let messages: [Message]
    }
    
    struct Message: Codable {
        let role: String
        let content: [Content]
    }
    
    struct Content: Codable {
        let type: String
        let text: String
    }
    
    struct ClaudeResponse: Codable {
        struct Response: Codable {
            let text: String
        }
        
        let delta: Response
    }
    
    func getChatResponse(_ message: String, imagesList: [String], chatHistoryList: [MessageRow], aiModel: String) async throws -> AsyncThrowingStream<String, Error> {
        let apiURL = URL(string: "https://api.anthropic.com/v1/messages")!
        
        var contentList: [[String: Any]] = [["type": "text", "text": message]]
        
        for index in 0..<imagesList.count {
            contentList.insert([
                "type": "text",
                "text": "Image: \(index + 1)"
            ], at: 0)
            contentList.insert([
                "type": "image",
                "source": [
                    "type": "base64",
                    "media_type": "image/jpeg",
                    "data": imagesList[index],
                ],
            ], at: 1)
        }
        
        var messagesList = [["role": "user", "content": contentList]]
        
        chatHistoryList.forEach { ch in
            messagesList.insert(["role": "user", "content": ch.sendText], at: 0)
            messagesList.insert(["role": "assistant", "content": ch.responseText ?? ""], at: 1)
        }
        
        let requestPayload: [String: Any] = [
            "model": aiModel,
            "max_tokens": 2048,
            "stream": true,
            "messages": messagesList
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: requestPayload, options: [])
        
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.addValue(AppConstants.shared.claudeApiKey, forHTTPHeaderField: "x-api-key")
        request.addValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.bytes(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "Invalid response", code: 0, userInfo: nil)
        }
        
        return AsyncThrowingStream<String, Error> { continuation in
            Task(priority: .userInitiated) {
                do {
                    for try await line in data.lines {
                        if line.hasPrefix("data: "), let data = line.dropFirst(6).data(using: .utf8), let text = try? JSONDecoder().decode(ClaudeResponse.self, from: data).delta.text {
                            continuation.yield(text)
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
