//
//  StabilyAiApi.swift
//  ChatAI
//
//  Created by Petru Grigor on 18.02.2025.
//

import Foundation
import UIKit

class StabilyAiApi {
    static let shared = StabilyAiApi()
    
    func generateImage(_ prompt: String, style: String, aspectRatio: String) async throws -> UIImage {
        guard let url = URL(string: "https://api.codbun.com/api/stability/generate-image?prompt=\(prompt)&aspectRatio=\(aspectRatio)&style=\(style)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return try await withCheckedThrowingContinuation { continuation in
            let task = URLSession.shared.downloadTask(with: request) { tempURL, response, error in
                if let error = error {
                    print("Request failed: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid HTTP response")
                    continuation.resume(throwing: URLError(.badServerResponse))
                    return
                }
                
                print("HTTP Status Code: \(httpResponse.statusCode)")
                
                guard let tempURL = tempURL else {
                    print("No data received")
                    continuation.resume(throwing: URLError(.cannotDecodeContentData))
                    return
                }
                
                do {
                    let imageData = try Data(contentsOf: tempURL)
                    guard let image = UIImage(data: imageData) else {
                        print("Failed to decode image")
                        continuation.resume(throwing: URLError(.cannotDecodeContentData))
                        return
                    }
                    
                    continuation.resume(returning: image)
                } catch {
                    print("Error reading downloaded file: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                }
            }
            
            task.resume()
        }
    }
}
