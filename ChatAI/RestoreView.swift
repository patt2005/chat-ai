//
//  RestoreView.swift
//  ChatAI
//
//  Created by Petru Grigor on 30.01.2025.
//

import SwiftUI
import SuperwallKit

struct RestoreView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text("🔄 Restore & Refund Assistance")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 5)
                
                Text("If you need to restore your purchase or request a refund, follow the steps below.")
                    .font(.body)
                    .foregroundColor(.gray)
                
                Divider().background(Color.gray.opacity(0.5))
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("✅ Restore Your Purchase")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    Text("""
                    1. Open the **App Store** on your device.
                    2. Tap on your **profile icon** (top-right corner).
                    3. Select **Manage Subscriptions**.
                    4. Find our app and ensure your subscription is active.
                    5. If necessary, tap **Restore Purchases** below.
                    """)
                }
                
                Button(action: {
                    Task {
                        await Superwall.shared.restorePurchases()
                    }
                }) {
                    Text("Restore Purchases")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.top, 5)
                
                Divider().background(Color.gray.opacity(0.5))
                
                // Refund Request Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("💰 Request a Refund")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    Text("""
                    1. Go to Apple's official refund request page.
                    2. **Sign in** with your Apple ID.
                    3. Under **"What can we help you with?"**, select **"Request a refund"**.
                    4. Choose the reason for your refund request and tap **Next**.
                    5. Select our app from your purchase list and submit your request.
                    6. Apple will review your request and notify you via **email**.
                    """)
                    
                    Button(action: {
                        if let url = URL(string: "https://reportaproblem.apple.com") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text("Request a Refund")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                }
                
                Divider().background(Color.gray.opacity(0.5))
                
                // Cancel Subscription Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("❌ Cancel Your Subscription")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    Text("""
                    1. **Open Settings** on your iPhone or iPad.
                    2. Tap **Your Apple ID (your name at the top)**.
                    3. Select **Subscriptions**.
                    4. Locate our app’s subscription and tap it.
                    5. Tap **Cancel Subscription** and confirm.
                    """)
                }
                
                Divider().background(Color.gray.opacity(0.5))
                
                // Feedback Section
                Text("💡 Need Help?")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Text("If you have any questions or feedback, feel free to contact us. We appreciate your support!")
                    .font(.body)
                    .foregroundColor(.gray)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Restore & Refund")
        .background(AppConstants.shared.backgroundColor.edgesIgnoringSafeArea(.all))
    }
}

// Preview
struct RestoreView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RestoreView()
        }
    }
}
