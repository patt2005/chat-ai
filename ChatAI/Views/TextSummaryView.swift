//
//  YoutubeSummaryView.swift
//  ChatAI
//
//  Created by Petru Grigor on 09.01.2025.
//

import SwiftUI

struct ActivityView: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct TextSummaryView: View {
    let text: String
    
    @State private var isSharing: Bool = false
    @State private var isCopied: Bool = false
    
    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        ZStack {
            ScrollView {
                Text(text)
                    .font(.body)
                    .foregroundStyle(.white)
                    .padding()
                    .padding(.bottom, 100)
            }
            .background(AppConstants.shared.backgroundColor)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Summary")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        impactFeedback.impactOccurred()
                        isSharing = true
                    }) {
                        ZStack {
                            Rectangle()
                                .foregroundColor(AppConstants.shared.grayColor)
                                .frame(width: 35, height: 35)
                                .cornerRadius(17.5)
                            Image("share")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.black)
                                .frame(width: 17.5, height: 17.5)
                        }
                    }
                }
            }
            .sheet(isPresented: $isSharing) {
                ActivityView(activityItems: [text])
            }
            .onAppear {
                impactFeedback.prepare()
            }
            
            VStack {
                Spacer()
                Button(action: {
                    UIPasteboard.general.string = text
                    isCopied = true
                    impactFeedback.impactOccurred()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isCopied = false
                    }
                }) {
                    HStack {
                        Image(systemName: "doc.on.doc")
                            .font(.headline)
                            .foregroundColor(.black)
                        Text("Copy")
                            .font(.headline)
                            .foregroundColor(.black)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppConstants.shared.primaryColor)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                }
                .padding(.bottom, 20)
                .padding(.horizontal)
                
                if isCopied {
                    Text("Copied to clipboard!")
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(.bottom, 10)
                        .transition(.opacity)
                }
            }
        }
    }
}
