//
//  ImageGenerationPopupView.swift
//  ChatAI
//
//  Created by Petru Grigor on 09.01.2025.
//

import SwiftUI

struct ImageGenerationPopupView: View {
    @Binding var isPresented: Bool
    @Binding var isLoading: Bool
    @Binding var showError: Bool
    
    @State private var promptText: String = ""
    @State private var selectedResolution: String = "1024x1024"
    @ObservedObject private var appProvider = AppProvider.shared
    
    let resolutions = ["1024x1024", "1024x1792", "1792x1024"]
    
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
                        Text("Generate Image")
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
                    
                    TextField("Enter a prompt for image generation", text: $promptText)
                        .padding(.leading, 25)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        .overlay(
                            HStack {
                                Image(systemName: "paintbrush")
                                    .foregroundColor(.gray)
                                    .padding(.leading, 10)
                                Spacer()
                            }
                        )
                    
                    Picker("Select Resolution", selection: $selectedResolution) {
                        ForEach(resolutions, id: \.self) { resolution in
                            Text(resolution)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.top, 10)
                    
                    Text("Enter your prompt and select the desired resolution.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        guard !promptText.isEmpty else { return }
                        
                        withAnimation {
                            isPresented = false
                            isLoading = true
                        }
                        
                        Task {
                            do {
                                let generatedImage = try await OpenAiApi().generateImage(promptText, size: selectedResolution)
                                
                                appProvider.navigationPath.append(.imageDataView(data: generatedImage))
                            } catch {
                                print("Caught an error: \(error.localizedDescription)")
                                showError = true
                            }
                            
                            isLoading = false
                            promptText = ""
                        }
                    }) {
                        Text("Generate")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(promptText.isEmpty ? Color.gray : AppConstants.shared.primaryColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .opacity(promptText.isEmpty ? 0.5 : 1.0)
                    }
                    .disabled(promptText.isEmpty)
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
