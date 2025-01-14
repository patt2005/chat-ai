//
//  AnalyticsManager.swift
//  ChatAI
//
//  Created by Petru Grigor on 14.01.2025.
//

import Foundation
import FirebaseAnalytics

class AnalyticsManager {
    static let shared = AnalyticsManager()
    
    private init() {}
    
    func logEvent(name: String, params: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: params)
    }
    
    func setUserId(userId: String) {
        Analytics.setUserID(userId)
    }
    
    func setUserProperty(value: String?, property: String) {
        Analytics.setUserProperty(value, forName: property)
    }
}
