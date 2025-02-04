//
//  ImageDataView.swift
//  ChatAI
//
//  Created by Petru Grigor on 09.01.2025.
//

import SwiftUI
import PhotosUI

struct ImageDataView: View {
    let data: ImageGenerationData
    
    @State private var isSharing: Bool = false
    @State private var showSuccessAlert: Bool = false
    
    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    private func saveImageToPhotos(from urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("Failed to decode image data")
                return
            }
            
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAsset(from: image)
                    }) { success, error in
                        if success {
                            print("Image saved to photo library successfully")
                            showSuccessAlert = true
                        } else {
                            print("Error saving image: \(error?.localizedDescription ?? "Unknown error")")
                        }
                    }
                } else {
                    print("Photo library access not authorized")
                }
            }
        }.resume()
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                AsyncImage(url: URL(string: data.url)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: 300)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(8)
                            .shadow(radius: 5)
                    case .failure:
                        Image(systemName: "xmark.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 300)
                .padding(.horizontal)
                
                Button(action: {
                    saveImageToPhotos(from: data.url)
                }) {
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("Download Image")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppConstants.shared.primaryColor)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
                .padding(.horizontal, 50)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Revised Prompt")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(data.revised_prompt)
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                        
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .padding(.top)
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
                            .frame(width: 17.5, height: 17.5)
                    }
                }
            }
        }
        .sheet(isPresented: $isSharing) {
            ActivityView(activityItems: [data.url])
        }
    }
}
