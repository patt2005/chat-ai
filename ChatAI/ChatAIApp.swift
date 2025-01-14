//
//  ChatAIApp.swift
//  ChatAI
//
//  Created by Petru Grigor on 26.12.2024.
//

import SwiftUI
import FirebaseCore
import RevenueCat
import SuperwallKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: AppConstants.shared.revenueCatApiKey)
        
        FirebaseApp.configure()
        
        Superwall.configure(apiKey: AppConstants.shared.superWallApiKey)
        
        purchaseController.syncSubscriptionStatus()
        
        return true
    }
}

@main
struct ChatAIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }
    }
}
