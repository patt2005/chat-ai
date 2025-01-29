//
//  UserApi.swift
//  ChatAI
//
//  Created by Petru Grigor on 29.01.2025.
//

import Foundation

class UserAPI {
    static let shared = UserAPI()
    
    private init() {}
    
    var userId: String = ""
    
    func registerUser(withId id: String) async throws {
        guard let url = URL(string: "http://localhost:5287/api/user/register-user?applicationCode=\(AppConstants.shared.appCode)") else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["appVersion": AppConstants.shared.appVersion, "fireBaseId": userId]
        
        let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
        request.httpBody = jsonData
        
        _ = try await URLSession.shared.data(for: request)
    }
}
