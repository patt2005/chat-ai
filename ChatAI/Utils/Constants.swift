//
//  Constants.swift
//  ChatAI
//
//  Created by Petru Grigor on 26.12.2024.
//

import SwiftUI
import AVFoundation

let purchaseController = RCPurchaseController()

class AppConstants {
    static let shared = AppConstants()
    
    let appVersion = "1.0.27"
    
    let backgroundColor = Color("BackgroundColor")
    let primaryColor = Color("AccentColor")
    let grayColor = Color(hex: "#222224")
    
    let revenueCatApiKey = "appl_XoAdMiLzAeolMowFFOghocvoFQs"
    let superWallApiKey = "pk_9c6b16267658b61dce6b3efd512cf7fff03930b2acca64e7"
    
    struct ChatModelsApiResponse: Decodable {
        struct ChatSnippets: Decodable {
            struct ChatInfo: Decodable {
                let Endpoint: String
                let Models: [String:String]
            }
            
            let Qwen: ChatInfo
            let GPT: ChatInfo
            let Grok: ChatInfo
            let Claude: ChatInfo
            let Gemini: ChatInfo
        }
        
        let AppTitle: String
        let Chats: ChatSnippets
        let FreeDailyMessages: Int
    }
    
    @MainActor
    private func loadChatModels() async {
        guard let url = URL(string: "https://center.codbun.com/api/json/get-json?appId=2&jsonName=settings1") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(ChatModelsApiResponse.self, from: data)
            
            AppProvider.shared.appName = response.AppTitle
            AppProvider.shared.maxDailyMessages = response.FreeDailyMessages
            AppProvider.shared.loadMessagesCount()
            
            ClaudeAiApi.shared.modelsList = response.Chats.Claude.Models
            ClaudeAiApi.shared.apiEndpoint = response.Chats.Claude.Endpoint
            
            GeminiAiApi.shared.modelsList = response.Chats.Gemini.Models
            
            GrokAiApi.shared.modelsList = response.Chats.Grok.Models
            GrokAiApi.shared.apiEndpoint = response.Chats.Grok.Endpoint
            
            OpenAiApi.shared.modelsList = response.Chats.GPT.Models
            OpenAiApi.shared.apiEndpoint = response.Chats.GPT.Endpoint
            
            QwenApi.shared.modelsList = response.Chats.Qwen.Models
            QwenApi.shared.apiEndpoint = response.Chats.Qwen.Endpoint
        } catch {
            print("Can not load chat models: \(error.localizedDescription)")
        }
    }
    
    private init() {
        Task { @MainActor in
            await loadChatModels()
        }
    }
}

enum AssistantModelType: String, Codable {
    case openAi = "openAi"
    case claudeAi = "claudeAi"
    case gemini = "gemini"
    case qwen = "qwen"
    case grok = "grok"
}

func convertImageToBase64(image: UIImage) -> String? {
    guard let imageData = image.jpegData(compressionQuality: 1.0) else {
        return nil
    }
    return imageData.base64EncodedString()
}

enum NavigationDestination: Hashable {
    case chatView(_ prompt: String = "", model: AssistantModel = AssistantModel(name: "Chat GPT", avatar: "chatgpt", apiModel: OpenAiApi.shared, type: .openAi), history: ChatHistoryEntity? = nil)
    case summaryView(text: String)
    case imageDataView(data: ImageGenerationData)
    case speachDetailsView(audioFilePath: String)
    case restoreView
    case manageSubscriptionView
    case chatPdfView(pdfData: Data)
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension UIImage {
    /// Resize image while keeping the aspect ratio. Original image is not modified.
    /// - Parameters:
    ///   - width: A new width in pixels.
    ///   - height: A new height in pixels.
    /// - Returns: Resized image.
    func resize(_ width: Int, _ height: Int) -> UIImage {
        let maxSize = CGSize(width: width, height: height)
        
        let availableRect = AVFoundation.AVMakeRect(
            aspectRatio: self.size,
            insideRect: .init(origin: .zero, size: maxSize)
        )
        let targetSize = availableRect.size
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        
        let resized = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        
        return resized
    }
}
