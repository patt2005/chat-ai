//
//  GeminiAiApi.swift
//  ChatAI
//
//  Created by Petru Grigor on 30.12.2024.
//

import Foundation
import FirebaseVertexAI
import SwiftUI
import PDFKit

class GeminiAiApi: AiModel {
    var modelsList: [String: String] = [:]
    var apiEndpoint: String = ""
    
    static var shared: any AiModel = GeminiAiApi()
    
    private func extractTextFromPDF(pdfData: Data) -> String {
        guard let pdfDocument = PDFDocument(data: pdfData) else { return "" }
        
        var extractedText = ""
        
        for pageIndex in 0..<pdfDocument.pageCount {
            if let page = pdfDocument.page(at: pageIndex), let pageText = page.string {
                extractedText += pageText + "\n\n"
            }
        }
        
        return extractedText
    }
    
    private let vertex = VertexAI.vertexAI()
    
    func getChatResponse(_ message: String, imagesList: [String], chatHistoryList: [MessageRow], aiModel: String) async throws -> AsyncThrowingStream<String, Error> {
        let model = vertex.generativeModel(modelName: aiModel)
        
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
                        continuation.yield(cleanResponseText(text))
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
    
    private func cleanResponseText(_ text: String) -> String {
        var cleanedText = text
        
        cleanedText = cleanedText.replacingOccurrences(of: "\\*\\*(.*?)\\*\\*", with: "$1", options: .regularExpression)
        cleanedText = cleanedText.replacingOccurrences(of: "\\*(.*?)\\*", with: "$1", options: .regularExpression)
        
        cleanedText = cleanedText.replacingOccurrences(of: "(?m)^\\*\\s", with: "• ", options: .regularExpression)
        
        return cleanedText
    }
    
    func getPDFSummary(pdfData: Data, prompt: String) async throws -> AsyncThrowingStream<String, Error> {
        let model = vertex.generativeModel(modelName: "gemini-1.5-flash")
        
        let fullText = extractTextFromPDF(pdfData: pdfData)
        
        let contentStream = try model.generateContentStream("\(prompt) \n\n PDF Text: \n\n \(fullText)")
        
        return AsyncThrowingStream<String, Error> { continuation in
            Task(priority: .userInitiated) {
                for try await line in contentStream {
                    if let text = line.text {
                        let cleanedText = cleanResponseText(text)
                        continuation.yield(cleanedText)
                    }
                }
                continuation.finish()
            }
        }
    }
}
