//
//  OpenAiApi.swift
//  ChatAI
//
//  Created by Petru Grigor on 27.12.2024.
//

import Foundation

enum ApiAnalysisError: Error {
    case invalidData
    case invalidResponse
}

class OpenAiApi: AiModel {
    struct CompletionResponse: Decodable {
        struct Choice: Decodable {
            let delta: Delta
        }
        
        struct Delta: Decodable {
            let content: String
        }
        
        let choices: [Choice]
    }
    
    var modelsList: [String: String] = [:]
    
    static var shared: any AiModel = OpenAiApi()
    
    private func cleanResponseText(_ text: String) -> String {
        var cleanedText = text
        
        cleanedText = cleanedText.replacingOccurrences(of: "\\*\\*(.*?)\\*\\*", with: "$1", options: .regularExpression)
        cleanedText = cleanedText.replacingOccurrences(of: "\\*(.*?)\\*", with: "$1", options: .regularExpression)
        
        cleanedText = cleanedText.replacingOccurrences(of: "###\\s*", with: "", options: .regularExpression)
        
        cleanedText = cleanedText.replacingOccurrences(of: "(?m)^-\\s", with: "• ", options: .regularExpression)
        
        return cleanedText
    }
    
    func getChatResponse(_ message: String, imagesList: [String], chatHistoryList: [MessageRow], aiModel: String) async throws -> AsyncThrowingStream<String, Error> {
        let url = URL(string: "https://api.codbun.com/api/chatgpt/chat")!
        
        let headers = [
            "Content-Type": "application/json",
        ]
        
        var messages: [[String: Any]] = [
            [
                "role": "developer",
                "content": "You are Chat GPT, a helpful assistant. You can answer any questions that user has."
            ]
        ]
        
        chatHistoryList.forEach { chatHistory in
            messages.append([
                "role": "user",
                "content": chatHistory.sendText
            ])
            messages.append([
                "role": "developer",
                "content": chatHistory.responseText ?? ""
            ])
        }
        
        var userMessageContent: [[String: Any]] = [
            ["type": "text", "text": message],
        ]
        
        imagesList.forEach { image in
            userMessageContent.append(
                ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(image)"]]
            )
        }
        
        messages.append([
            "role": "user",
            "content": userMessageContent,
        ])
        
        let requestBody: [String: Any] = [
            "model": aiModel,
            "messages": messages,
            "stop": [
                "\n\n\n",
                "<|im_end|>"
            ],
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

extension OpenAiApi {
    func generateSpeach(_ prompt: String, voice: String) async throws -> String {
        guard let url = URL(string: "https://api.codbun.com/api/chatgpt/generate-audio") else { throw URLError(.badURL) }
        
        let headers = [
            "Content-Type": "application/json",
        ]
        
        let body: [String: Any] = [
            "model": "tts-1",
            "input": prompt,
            "voice": voice,
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            throw NSError(domain: "Invalid JSON", code: 0, userInfo: nil)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let tempFileUrl = FileManager.default.temporaryDirectory.appendingPathComponent("speech.mp3")
        
        if FileManager.default.fileExists(atPath: tempFileUrl.path) {
            try FileManager.default.removeItem(at: tempFileUrl)
        }
        
        try data.write(to: tempFileUrl)
        
        return tempFileUrl.path
    }
}
