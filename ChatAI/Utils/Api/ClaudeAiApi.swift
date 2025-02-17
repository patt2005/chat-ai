//
//  ClaudeAiApi.swift
//  ChatAI
//
//  Created by Petru Grigor on 27.12.2024.
//

import Foundation
import SwiftUI

class ClaudeAiApi: AiModel {    
    var modelsList: [String: String] = [:]
    var apiEndpoint: String = ""
    
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
        let apiURL = URL(string: "\(apiEndpoint)/chat")!
        
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
        
        var messagesList: [[String: Any]] = []
        
        chatHistoryList.forEach { ch in
            messagesList.append(["role": "user", "content": ch.sendText])
            messagesList.append(["role": "assistant", "content": ch.responseText == "" ? "No response was generated." : ch.responseText ?? "No response was generated." ])
        }
        
        messagesList.append(["role": "user", "content": contentList])
        
        let requestPayload: [String: Any] = [
            "model": aiModel,
            "max_tokens": 2048,
            "stream": true,
            "messages": messagesList
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: requestPayload, options: [])
        
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
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
