//
//  GeminiAiApi.swift
//  ChatAI
//
//  Created by Petru Grigor on 30.12.2024.
//

import Foundation
import FirebaseVertexAI
import SwiftUI

class GeminiAiApi: AiModel {
    static var shared: any AiModel = GeminiAiApi()
    
    private let vertex = VertexAI.vertexAI()
    
    func getChatResponse(_ message: String, imagesList: [String], chatHistoryList: [MessageRow]) async throws -> AsyncThrowingStream<String, Error> {
        let model = vertex.generativeModel(modelName: "gemini-1.5-flash")
        
        let uiImages = imagesList.compactMap { base64String -> UIImage? in
            if let imageData = Data(base64Encoded: base64String) {
                return UIImage(data: imageData)
            }
            return nil
        }
        
        let contentStream: AsyncThrowingStream<GenerateContentResponse, Error>
        if uiImages.isEmpty {
            contentStream = try model.generateContentStream(message)
        } else if uiImages.count == 1 {
            contentStream = try model.generateContentStream(uiImages.first!, message)
        } else {
            contentStream = try model.generateContentStream(uiImages.first!, uiImages[1], message)
        }
        
        return AsyncThrowingStream<String, Error> { continuation in
            Task(priority: .userInitiated) {
                for try await line in contentStream {
                    if let text = line.text {
                        continuation.yield(text.replacingOccurrences(of: "**", with: ""))
                    }
                }
                continuation.finish()
            }
        }
    }
}

extension GeminiAiApi {
    func getYoutubeSummary(_ url: String) async throws -> String {
        let model = vertex.generativeModel(modelName: "gemini-1.5-flash")
        
        let video = FileDataPart(uri: url, mimeType: "video/mp4")
        
        let prompt = "You are an advanced AI assistant skilled in summarizing multimedia content. Your task is to watch and analyze the provided YouTube video and generate a clear, concise, and accurate summary of its content. Focus on capturing the main ideas, key points, and any important details while ignoring filler or irrelevant information. Ensure the summary is easy to understand and provides valuable insights to someone who has not watched the video."
        
        let contentStream = try await model.generateContent(video, prompt)
        
        let filteredText = contentStream.text?.replacingOccurrences(of: "**", with: "")
        
        return filteredText ?? ""
    }
    
    func getPDFSummary(pdfFile: URL) async throws -> String {
        let fileManager = FileManager.default
        let isReadable = fileManager.isReadableFile(atPath: pdfFile.path)
        
        if !isReadable {
            throw NSError(domain: "FilePermissionError", code: 403, userInfo: [NSLocalizedDescriptionKey: "No permission to read the file at \(pdfFile.path)"])
        }
        
        let model = vertex.generativeModel(modelName: "gemini-1.5-flash")
        
        if pdfFile.startAccessingSecurityScopedResource() {
            defer { pdfFile.stopAccessingSecurityScopedResource() }
            
            do {
                let pdfData = try Data(contentsOf: pdfFile)
                let pdfFilePart = InlineDataPart(data: pdfData, mimeType: "application/pdf")
                
                let prompt = "You are an AI assistant that summarizes PDF documents. Extract key points concisely."
                
                let contentStream = try await model.generateContent(pdfFilePart, prompt)
                
                return contentStream.text?.replacingOccurrences(of: "**", with: "") ?? ""
            } catch {
                throw NSError(domain: "FileReadError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to read the PDF file: \(error.localizedDescription)"])
            }
        } else {
            throw NSError(domain: "FilePermissionError", code: 403, userInfo: [NSLocalizedDescriptionKey: "Cannot access the selected file."])
        }
    }
}
