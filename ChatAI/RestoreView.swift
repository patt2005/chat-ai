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
                Text("🔄 Restore Assistance")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 5)
                
                Text("If you need to restore your purchase, follow the steps below.")
                    .font(.body)
                    .foregroundColor(.gray)
                
                Divider().background(Color.gray.opacity(0.5))
                    .padding(.vertical)
                
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
                    .padding(.vertical)
            }
            .padding()
        }
        .navigationTitle("Restore Purchase")
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
