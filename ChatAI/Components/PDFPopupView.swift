//
//  PDFPopupView.swift
//  ChatAI
//
//  Created by Petru Grigor on 13.01.2025.
//

import SwiftUI

struct PDFPopupView: View {
    @Binding var isPresented: Bool
        @Binding var isLoading: Bool
        @Binding var showError: Bool
        
        @State private var pdfFile: URL? = nil
        @State private var showingFilePicker = false
        
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
                            Text("Get PDF Summary")
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
                        
                        Button(action: {
                            showingFilePicker = true
                        }) {
                            HStack {
                                Image(systemName: "doc.text")
                                    .font(.title3)
                                    .foregroundColor(.gray)
                                Text(pdfFile == nil ? "Upload PDF" : pdfFile?.lastPathComponent ?? "")
                                    .font(.body)
                                    .foregroundColor(.primary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)
                        }
                        .fileImporter(isPresented: $showingFilePicker, allowedContentTypes: [.pdf]) { result in
                            switch result {
                            case .success(let url):
                                pdfFile = url
                            case .failure:
                                showError = true
                            }
                        }
                        
                        Text("Generate a concise summary of your uploaded PDF.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            guard let pdfFile = pdfFile else { return }
                            
                            withAnimation {
                                isPresented = false
                                isLoading = true
                            }
                            
                            Task {
                                do {
                                    let response = try await GeminiAiApi().getPDFSummary(pdfFile: pdfFile)
                                    
                                    appProvider.navigationPath.append(.summaryView(text: response))
                                } catch {
                                    showError = true
                                }
                                
                                isLoading = false
                                self.pdfFile = nil
                            }
                        }) {
                            Text("Generate Summary")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(pdfFile == nil ? Color.gray : AppConstants.shared.primaryColor)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .opacity(pdfFile == nil ? 0.5 : 1.0)
                        }
                        .disabled(pdfFile == nil)
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
