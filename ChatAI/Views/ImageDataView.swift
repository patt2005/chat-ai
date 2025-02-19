//
//  ImageDataView.swift
//  ChatAI
//
//  Created by Petru Grigor on 09.01.2025.
//

import SwiftUI
import PhotosUI

struct ImageDataView: View {
    let image: UIImage
    let generatedDate: String = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short)
    let aspectRatio: String
    let style: String

    @State private var isSharing: Bool = false
    @State private var showSuccessAlert: Bool = false
    
    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    private func saveImageToPhotos() {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }) { success, error in
                    if success {
                        showSuccessAlert = true
                    } else {
                        print("Error saving image: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            } else {
                print("Photo library access not authorized")
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .shadow(radius: 10)
                        .padding()
                }
                .background(Color.black.opacity(0.2))
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.2), lineWidth: 1))
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("📅 Generated on: \(generatedDate)")
                    Text("🎨 Style: \(style)")
                    Text("📐 Aspect Ratio: \(aspectRatio)")
                }
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .padding()
                .background(Color.black.opacity(0.3))
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.2), lineWidth: 1))
                .padding(.horizontal)
                
                VStack(spacing: 12) {
                    Button(action: {
                        saveImageToPhotos()
                    }) {
                        HStack {
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.headline)
                            Text("Download Image")
                                .fontWeight(.medium)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                    }
                    .padding(.horizontal, 40)

                    Button(action: {
                        impactFeedback.impactOccurred()
                        isSharing = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .font(.headline)
                            Text("Share Image")
                                .fontWeight(.medium)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                    }
                    .padding(.horizontal, 40)
                }
            }
            .padding(.vertical, 20)
        }
        .background(AppConstants.shared.backgroundColor)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Success", isPresented: $showSuccessAlert, actions: {
            Button("OK", role: .cancel) {}
        }, message: {
            Text("The image was successfully saved.")
        })
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Image Details")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
        }
        .sheet(isPresented: $isSharing) {
            ActivityView(activityItems: [image])
        }
    }
}
