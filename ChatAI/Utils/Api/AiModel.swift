//
//  AiModel.swift
//  ChatAI
//
//  Created by Petru Grigor on 30.12.2024.
//

import Foundation

protocol AiModel {
    static var shared: any AiModel { get set }
    
    func getChatResponse(_ message: String, imagesList: [String], chatHistoryList: [MessageRow]) async throws -> AsyncThrowingStream<String, Error>
}
