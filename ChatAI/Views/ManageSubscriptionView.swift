//
//  ManageSubscriptionView.swift
//  ChatAI
//
//  Created by Petru Grigor on 01.02.2025.
//

import SwiftUI

struct ManageSubscriptionView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Divider().background(Color.gray.opacity(0.5))
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("✅ Manage Your Subscription")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    Text("""
                                    1. **Open Settings** on your iPhone or iPad.
                                    2. Tap **Your Apple ID (your name at the top)**.
                                    3. Select **Subscriptions**.
                                    4. Find the subscription related to our app and tap it.
                                    5. Tap **Cancel Subscription** and confirm.
                                    """)
                }
                
                Link(destination: URL(string: "https://apps.apple.com/account/subscriptions")!) {
                    Text("Manage Subscription")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.top, 5)
                }
                
                Divider().background(Color.gray.opacity(0.5))
                
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
        .navigationTitle("Manage Subscription")
        .background(AppConstants.shared.backgroundColor.edgesIgnoringSafeArea(.all))
    }
}
