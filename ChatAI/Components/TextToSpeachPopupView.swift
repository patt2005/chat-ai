//
//  TextToSpeachPopupView.swift
//  ChatAI
//
//  Created by Petru Grigor on 13.01.2025.
//

import SwiftUI

struct TextToSpeachPopupView: View {
    @Binding var isPresented: Bool
    @Binding var isLoading: Bool
    @Binding var showError: Bool
    
    @State private var inputText: String = ""
    @State private var selectedVoice: String = "alloy"
    
    let voices = ["alloy", "ash", "coral", "echo", "fable", "onyx", "nova", "sage", "shimmer"]
    
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
                        Text("Text to Speech")
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
                    
                    TextField("Enter text to convert to speech", text: $inputText)
                        .padding(.leading, 28)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        .overlay(
                            HStack {
                                Image(systemName: "textformat.alt")
                                    .foregroundColor(.gray)
                                    .padding(.leading, 10)
                                Spacer()
                            }
                        )
                    
                    HStack {
                        Text("Select Voice")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Picker("Selected Voice", selection: $selectedVoice) {
                            ForEach(voices, id: \.self) { voice in
                                Text(voice.capitalized).tag(voice)
                            }
                        }
                        .padding(4)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                    }
                    
                    Text("Convert text to speech using the selected voice.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        guard !inputText.isEmpty else { return }
                        
                        withAnimation {
                            isPresented = false
                            isLoading = true
                        }
                        
                        Task {
                            do {
                                let audioFile = try await OpenAiApi().generateSpeach(inputText, voice: selectedVoice)
                                
                                appProvider.navigationPath.append(.speachDetailsView(audioFilePath: audioFile))
                            } catch {
                                showError = true
                            }
                            
                            isLoading = false
                            inputText = ""
                        }
                    }) {
                        Text("Generate Speech")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(inputText.isEmpty ? Color.gray : AppConstants.shared.primaryColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .opacity(inputText.isEmpty ? 0.5 : 1.0)
                    }
                    .disabled(inputText.isEmpty)
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
