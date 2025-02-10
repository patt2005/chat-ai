//
//  ChatPdfView.swift
//  ChatAI
//
//  Created by Petru Grigor on 02.02.2025.
//

import SwiftUI
import Combine

class ChatPdfViewModel: ObservableObject {
    @Published var inputText: String = ""
    @Published var isInteracting: Bool = false
    @Published var messages: [MessageRow] = []
    
    @ObservedObject var appProvider = AppProvider.shared
    
    @Published var isImageViewPresented: Bool = false
    @Published var selectedImageToView: UIImage?
    
    private var pdfData: Data
    
    @MainActor
    func sendTapped() async {
        let text = inputText
        inputText = ""
        await send(text)
    }
    
    init(pdfData: Data) {
        self.pdfData = pdfData
    }
    
    func scrollToBottom(proxy: ScrollViewProxy) {
        guard let id = self.messages.last?.id else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.3)) {
                proxy.scrollTo(id, anchor: .bottom)
            }
        }
    }
    
    @MainActor
    func retry(messageRow: MessageRow) async {
        let index = messages.firstIndex { message in
            return messageRow.id == message.id
        }
        
        guard let index = index else { return }
        
        messages.remove(at: index)
        await send(messageRow.sendText)
    }
    
    @MainActor
    private func send(_ text: String) async {
        isInteracting = true
        var streamText = ""
        
        var messageRow = MessageRow(isInteracting: true, sendText: text, responseImage: "pdf", responseText: streamText, uploadedImages: [])
        self.messages.append(messageRow)
        
        do {
            let stream = try await GeminiAiApi().getPDFSummary(pdfData: pdfData, prompt: text)
            for try await text in stream {
                streamText += text
                messageRow.responseText = streamText.trimmingCharacters(in: .whitespacesAndNewlines)
                self.messages[self.messages.count - 1] = messageRow
            }
        } catch {
            messageRow.responseError = error.localizedDescription
        }
        
        messageRow.isInteracting = false
        self.messages[self.messages.count - 1] = messageRow
        isInteracting = false
    }
}

struct ChatPdfView: View {
    @StateObject private var viewModel: ChatPdfViewModel
    
    @FocusState private var isFocused: Bool
    
    let pdfData: Data
    
    init(pdfData: Data) {
        self.pdfData = pdfData
        
        _viewModel = StateObject(wrappedValue: ChatPdfViewModel(pdfData: pdfData))
    }
    
    private func systemMessageBubble() -> some View {
        HStack(alignment: .top, spacing: 13) {
            Image("pdf")
                .resizable()
                .scaledToFit()
                .frame(width: 35, height: 35)
                .cornerRadius(17.5)
            
            VStack(alignment: .leading) {
                Text("Hi there! I am your PDF assistant. I’ll help you summarize or answer any questions about it!")
                    .multilineTextAlignment(.leading)
                    .textSelection(.enabled)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .backgroundStyle(AppConstants.shared.backgroundColor)
    }
    
    var body: some View {
        ScrollViewReader { reader in
            VStack {
                ScrollView {
                    VStack(spacing: 0) {
                        systemMessageBubble()
                        ForEach(viewModel.messages, id: \.id) { message in
                            MessageRowView(messageRow: message, retryCallback: { ms in
                                Task {
                                    await viewModel.retry(messageRow: ms)
                                }}, showImageContent: $viewModel.isImageViewPresented, selectedImage: $viewModel.selectedImageToView)
                        }
                    }
                }
                .onTapGesture {
                    isFocused = false
                }
                .onAppear {
                    viewModel.scrollToBottom(proxy: reader)
                }
                .onChange(of: viewModel.messages) { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        viewModel.scrollToBottom(proxy: reader)
                    }
                }
                
                VStack(alignment: .leading) {
                    HStack(alignment: .center, spacing: 5) {
                        TextField("Type a message...", text: $viewModel.inputText, axis: .vertical)
                            .lineLimit(1...4)
                            .padding(.horizontal, 6)
                            .padding(.leading, 8)
                            .foregroundColor(.white)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.sentences)
                            .focused($isFocused)
                            .onAppear {
                                guard let id = viewModel.messages.last?.id else { return }
                                reader.scrollTo(id, anchor: .bottom)
                            }
                        
                        Button(action: {
                            if !viewModel.isInteracting && !viewModel.inputText.isEmpty {
                                Task {
                                    await viewModel.sendTapped()
                                    viewModel.scrollToBottom(proxy: reader)
                                }
                            }
                        }) {
                            if !viewModel.isInteracting {
                                Image(systemName: "paperplane.fill")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(7)
                                    .background(AppConstants.shared.primaryColor)
                                    .clipShape(Circle())
                                    .padding(.trailing, 10)
                            } else {
                                ProgressView()
                                    .frame(width: 20, height: 35)
                                    .padding(.trailing, 20)
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.2))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                .frame(maxWidth: .infinity)
                .cornerRadius(20)
                .padding(.horizontal, 15)
                .padding(.vertical, 14)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Image("pdf")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .cornerRadius(15)
                        
                        Text("PDF Assistant")
                            .font(.headline.bold())
                    }
                }
            }
        }
        .background(AppConstants.shared.backgroundColor)
        .preferredColorScheme(.dark)
    }
}

