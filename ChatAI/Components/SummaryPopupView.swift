//
//  PopUpView.swift
//  ChatAI
//
//  Created by Petru Grigor on 02.01.2025.
//

import SwiftUI

struct SummaryPopupView: View {
    @Binding var isPresented: Bool
    @Binding var isLoading: Bool
    @Binding var showError: Bool
    
    @State private var videoLink: String = ""
    
    @ObservedObject private var appProvider = AppProvider.shared
    
    var body: some View {
        ZStack {
            if isPresented {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            isPresented = false
                        }
                    }
                    .transition(.opacity)
                
                VStack(spacing: 20) {
                    HStack {
                        Text("YouTube Summary")
                            .font(.headline)
                            .fontWeight(.bold)
                        Spacer()
                        Button(action: {
                            withAnimation {
                                isPresented = false
                            }
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    TextField("Paste YouTube video link", text: $videoLink)
                        .padding(.leading, 25)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        .overlay(
                            HStack {
                                Image(systemName: "link")
                                    .foregroundColor(.gray)
                                    .padding(.leading, 10)
                                Spacer()
                            }
                        )
                    
                    Text("Insert a link to the video to summarize.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        guard !videoLink.isEmpty else { return }
                        
                        withAnimation {
                            isPresented = false
                            isLoading = true
                        }
                        
                        Task {
                            do {
                                let text = try await GeminiAiApi().getYoutubeSummary(videoLink)
                                videoLink = ""
                                
                                appProvider.navigationPath.append(.summaryView(text: text))
                            } catch {
                                showError = true
                            }
                            isLoading = false
                        }
                    }) {
                        Text("Summarize")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(videoLink.isEmpty ? Color.gray : AppConstants.shared.primaryColor)
                            .foregroundColor(videoLink.isEmpty ? .white : .black)
                            .cornerRadius(10)
                            .opacity(videoLink.isEmpty ? 0.5 : 1.0)
                    }
                    .disabled(videoLink.isEmpty)
                }
                .transition(.opacity)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .padding(.horizontal, 30)
                .transition(.move(edge: .bottom))
                .zIndex(1)
            }
        }
    }
}
