//
//  SettingsView.swift
//  ChatAI
//
//  Created by Petru Grigor on 27.12.2024.
//

import SwiftUI

struct SettingsView: View {
    @State private var showDisclaimer: Bool = false
    @State private var isSharing = false
    
    @Environment(\.requestReview) var requestReview
    
    @ObservedObject private var provider = AppProvider.shared
    
    var body: some View {
        ZStack {
            AppConstants.shared.backgroundColor
                .edgesIgnoringSafeArea(.all)
            
            Form {
                Section(header: Text("Feedback")) {
                    Button(action: {
                        isSharing = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(AppConstants.shared.primaryColor)
                                .font(.title2)
                            Text("Share App")
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.leading, 8.5)
                        }
                    }
                    
                    Button(action: {
                        let email = "mihai@codbun.com"
                        let subject = "Support Request"
                        let body = "Hi, I need help with... (Qwently \(AppConstants.shared.appVersion))"
                        let mailtoURL = "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
                        
                        if let url = URL(string: mailtoURL) {
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            } else {
                                print("Mail app is not available")
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(AppConstants.shared.primaryColor)
                                .font(.title2)
                            Text("Contact us")
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    Button(action: {
                        requestReview()
                    }) {
                        HStack {
                            Image(systemName: "hand.thumbsup")
                                .foregroundColor(AppConstants.shared.primaryColor)
                                .font(.title2)
                            Text("Rate us")
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.leading, 5)
                        }
                    }
                }
                
                Section(header: Text("About Us")) {
                    Link(destination: URL(string: "https://www.linkedin.com/company/codbun")!) {
                        HStack {
                            Image(systemName: "person.2.fill")
                                .foregroundColor(AppConstants.shared.primaryColor)
                                .font(.headline)
                            Text("Follow us")
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    Link(destination: URL(string: "https://codbun.com/About")!) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(AppConstants.shared.primaryColor)
                                .font(.title2)
                            Text("About us")
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    Link(destination: URL(string: "https://codbun.com/Work")!) {
                        HStack {
                            Image(systemName: "app.badge")
                                .foregroundColor(AppConstants.shared.primaryColor)
                                .font(.title2)
                            Text("Our Apps")
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                
                Section(header: Text("Legal")) {
                    Button(action: {
                        provider.navigationPath.append(.restoreView)
                    }) {
                        HStack {
                            Image(systemName: "dollarsign.arrow.circlepath")
                                .foregroundColor(AppConstants.shared.primaryColor)
                                .font(.title3)
                            Text("Restore Purchase")
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    Link(destination: URL(string: "https://apps.codbun.com/qwently-ai/privacy")!) {
                        HStack {
                            Image(systemName: "lock.shield")
                                .foregroundColor(AppConstants.shared.primaryColor)
                                .font(.title2)
                            Text("Privacy Policy")
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    Link(destination: URL(string: "https://apps.codbun.com/qwently-ai/terms")!) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(AppConstants.shared.primaryColor)
                                .font(.title2)
                            Text("Terms of Use")
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    Button(action: {
                        provider.navigationPath.append(.manageSubscriptionView)
                    }) {
                        HStack {
                            Image(systemName: "creditcard.fill")
                                .foregroundColor(AppConstants.shared.primaryColor)
                                .font(.headline)
                            Text("Manage Subscription")
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .sheet(isPresented: $isSharing) {
            ActivityView(activityItems: [
                "https://apps.apple.com/us/app/chatbun-ai-chatbot-assistant/id6740526710"])
        }
        .preferredColorScheme(.dark)
    }
}
