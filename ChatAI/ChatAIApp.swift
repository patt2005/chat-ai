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
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: AppConstants.shared.revenueCatApiKey)
        
        Superwall.configure(apiKey: AppConstants.shared.superWallApiKey, purchaseController: purchaseController)
        
        purchaseController.syncSubscriptionStatus()
        
        UNUserNotificationCenter.current().delegate = self
        
        FirebaseApp.configure()
        
        Task {
            await handleNotificationPermissions(application: application)
        } 
        
        return true
    }
    
    @MainActor
    private func handleNotificationPermissions(application: UIApplication) async {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: authOptions)
            print("Notification authorization granted: \(granted)")
        } catch {
            print("Notification authorization error: \(error.localizedDescription)")
        }
        
        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async
    -> UNNotificationPresentationOptions {
        return [[.badge, .sound]]
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {}
}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else {
            print("No FCM token received")
            return
        }
        
        let dataDict: [String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"),
                                        object: nil,
                                        userInfo: dataDict)
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
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
