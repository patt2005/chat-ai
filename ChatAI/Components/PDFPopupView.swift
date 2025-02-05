//
//  PDFPopupView.swift
//  ChatAI
//
//  Created by Petru Grigor on 13.01.2025.
//

import SwiftUI

struct PDFPopupView: View {
    @Binding var isPresented: Bool
    @Binding var showError: Bool
    @State private var pdfFileData: Data? = nil
    @State private var pdfFilePath: URL? = nil
    
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
                        Text("Ask Your PDF")
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
                            Text(pdfFilePath == nil ? "Upload PDF" : pdfFilePath?.lastPathComponent ?? "")
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
                            if url.startAccessingSecurityScopedResource() {
                                defer { url.stopAccessingSecurityScopedResource() }
                                pdfFileData = try? Data(contentsOf: url)
                                pdfFilePath = url
                            } else {
                                showError = true
                                print("Failed to get permission to access file.")
                            }
                        case .failure:
                            showError = true
                        }
                    }
                    
                    Text("Ask a question and get insights from your uploaded PDF.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        guard let pdfFileData = pdfFileData else { return }
                        
                        withAnimation {
                            isPresented = false
                        }
                        
                        appProvider.navigationPath.append(.chatPdfView(pdfData: pdfFileData))
                        self.pdfFileData = nil
                        self.pdfFilePath = nil
                    }) {
                        Text("Ask PDF")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(pdfFileData == nil ? Color.gray : AppConstants.shared.primaryColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .opacity(pdfFileData == nil ? 0.5 : 1.0)
                    }
                    .disabled(pdfFileData == nil)
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
