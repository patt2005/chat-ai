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
    @State private var selectedStyle: String = "3D Model"
    @State private var selectedAspectRatio: String = "1:1"
    
    @ObservedObject private var appProvider = AppProvider.shared
    
    private let artStyles: [String: String] = [
        "Analog Film": "analog-film",
        "3D Model": "3d-model",
        "Anime": "anime",
        "Cinematic": "cinematic",
        "Comic Book": "comic-book",
        "Digital Art": "digital-art",
        "Enhance": "enhance",
        "Fantasy Art": "fantasy-art",
        "Isometric": "isometric",
        "Line Art": "line-art",
        "Low Poly": "low-poly",
        "Neon Punk": "neon-punk",
        "Origami": "origami",
        "Photographic": "photographic",
        "Pixel Art": "pixel-art",
        "Tile Texture": "tile-texture"
    ]
    
    private let aspectRatios = [
        "16:9", "1:1", "21:9", "2:3", "3:2",
        "4:5", "5:4", "9:16", "9:21"
    ]
    
    var body: some View {
        ZStack {
            if isPresented {
                Rectangle()
                    .fill(Color.clear)
                    .edgesIgnoringSafeArea(.all)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            isPresented = false
                            appProvider.showBlurOverlay = false
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
                                appProvider.showBlurOverlay = false
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
                    
                    HStack {
                        VStack(spacing: 0) {
                            Text("Style")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Picker("Style", selection: $selectedStyle) {
                                ForEach(Array(artStyles.keys), id: \.self) { key in
                                    Text(key).tag(key)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(maxWidth: 150, maxHeight: 120)
                            .clipped()
                        }
                        
                        VStack(spacing: 0) {
                            Text("Aspect Ratio")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Picker("Aspect Ratio", selection: $selectedAspectRatio) {
                                ForEach(aspectRatios, id: \.self) { ratio in
                                    Text(ratio).tag(ratio)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(maxWidth: 100, maxHeight: 120)
                            .clipped()
                        }
                    }
                    .padding(.horizontal, 5)
                    
                    Text("Enter your prompt and select the desired resolution.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        guard !promptText.isEmpty else { return }
                        
                        withAnimation {
                            isPresented = false
                            appProvider.showBlurOverlay = false
                            isLoading = true
                        }
                        
                        Task {
                            do {
                                let imageData = try await StabilyAiApi.shared.generateImage(promptText, style: artStyles[selectedStyle] ?? "", aspectRatio: selectedAspectRatio)
                                
                                appProvider.navigationPath.append(.imageDataView(image: imageData, style: selectedStyle, ratio: selectedAspectRatio))
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
                            .foregroundColor(promptText.isEmpty ? .white : .black)
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
