//
//  ChatView.swift
//  ChatAI
//
//  Created by Petru Grigor on 27.12.2024.
//

import SwiftUI
import Combine
import SuperwallKit

class ChatViewModel: ObservableObject {
    @Published var inputText: String = ""
    @Published var isInteracting: Bool = false
    @Published var messages: [MessageRow] = []
    
    @Published var uploadedImages: [UIImage] = []
    @Published var selectedImage: UIImage?
    @Published var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    @Published var isImageViewPresented: Bool = false
    @Published var selectedImageToView: UIImage?
    
    @Published var showImages: Bool = false
    
    @Published var pickedModel: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    @ObservedObject var appProvider = AppProvider.shared
    
    private let model: AssistantModel
    private var chatHistory: ChatHistoryEntity? = nil
    private var responseTask: Task<Void, Never>?
    
    @MainActor
    func sendTapped() async {
        let text = inputText
        inputText = ""
        await send(text)
    }
    
    init(_ model: AssistantModel, history: ChatHistoryEntity? = nil) {
        self.model = model
        
        if let history {
            self.chatHistory = history
            self.messages = history.messages
        }
        
        pickedModel = self.model.apiModel.modelsList.keys.first ?? ""
        
        $selectedImage.sink { newImage in
            if let image = newImage {
                self.uploadedImages.append(image)
                self.showImages = true
            }
        }
        .store(in: &cancellables)
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
    func cancelResponse() {
        responseTask?.cancel()
        isInteracting = false
        responseTask = nil
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
        
        let imagesList = uploadedImages.map { image in
            let resizedImage = image.resize(784, 1568)
            return convertImageToBase64(image: resizedImage) ?? ""
        }
        
        var messageRow = MessageRow(isInteracting: true, sendText: text, responseImage: model.avatar, responseText: streamText, uploadedImages: imagesList)
        self.messages.append(messageRow)
        self.showImages = false
        
        responseTask = Task {
            do {
                let stream = try await model.apiModel.getChatResponse(text, imagesList: imagesList, chatHistoryList: self.chatHistory?.messages ?? [], aiModel: model.apiModel.modelsList[pickedModel]!)
                for try await text in stream {
                    if Task.isCancelled { break }
                    streamText += text
                    messageRow.responseText = streamText.trimmingCharacters(in: .whitespacesAndNewlines)
                    self.messages[self.messages.count - 1] = messageRow
                }
                self.uploadedImages.removeAll()
            } catch let error as NSError {
                if error.domain == NSURLErrorDomain && error.code == -999 {
                    messageRow.responseError = nil
                } else {
                    messageRow.responseError = error.localizedDescription
                }
            }
            
            messageRow.isInteracting = false
            self.messages[self.messages.count - 1] = messageRow
            isInteracting = false
            
            if let chatHistory  {
                let foundChat = appProvider.chatHistory.first(where: { $0.id == chatHistory.id })!
                foundChat.messages = self.messages
            } else {
                appProvider.chatHistory.append(ChatHistoryEntity(id: UUID(), assistantModelType: self.model.type, messages: self.messages))
                self.chatHistory = appProvider.chatHistory.last
            }
            appProvider.saveChatHistory()
        }
    }
}

struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel
    
    @State private var showImagePicker = false
    
    @FocusState private var isFocused: Bool
    
    @Environment(\.requestReview) var requestReview
    
    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    let prompt: String
    let model: AssistantModel
    
    init(prompt: String, model: AssistantModel, chatHistory: ChatHistoryEntity? = nil) {
        self.prompt = prompt
        self.model = model
        
        _viewModel = StateObject(wrappedValue: ChatViewModel(model, history: chatHistory))
    }
    
    private func systemMessageBubble() -> some View {
        HStack(alignment: .top, spacing: 13) {
            Image(model.avatar)
                .resizable()
                .scaledToFit()
                .frame(width: 35, height: 35)
                .cornerRadius(17.5)
            
            VStack(alignment: .leading) {
                Text("Hi there! I am \(model.name). How can I help you today?")
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
                    impactFeedback.impactOccurred()
                    viewModel.scrollToBottom(proxy: reader)
                }
                .onChange(of: viewModel.messages) { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        viewModel.scrollToBottom(proxy: reader)
                    }
                }
                
                VStack(alignment: .leading) {
                    if !viewModel.uploadedImages.isEmpty && viewModel.showImages {
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 10) {
                                ForEach(Array(viewModel.uploadedImages.enumerated()), id: \.offset) { index, image in
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 80, height: 80)
                                            .cornerRadius(10)
                                            .clipped()
                                        
                                        Button(action: {
                                            viewModel.uploadedImages.remove(at: index)
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.gray)
                                                .background(Color.white.clipShape(Circle()))
                                        }
                                        .offset(x: -5, y: 7)
                                    }
                                }
                            }
                            .padding(.horizontal, 14)
                        }
                        .frame(height: 80)
                        .padding(.top, 5)
                    }
                    
                    HStack(alignment: .center, spacing: 0) {
                        Menu {
                            Button(action: {
                                viewModel.sourceType = .photoLibrary
                                showImagePicker = true
                            }) {
                                Label("Attach Photos", systemImage: "photo.on.rectangle.angled")
                            }
                            Button(action: {
                                viewModel.sourceType = .camera
                                showImagePicker = true
                            }) {
                                Label("Take Photo", systemImage: "camera.fill")
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        .sheet(isPresented: $showImagePicker) {
                            ImagePicker(selectedImage: $viewModel.selectedImage, isImagePickerPresented: $showImagePicker, sourceType: viewModel.sourceType)
                        }
                        .padding(.leading, 10)
                        .onAppear {
                            guard let id = viewModel.messages.last?.id else { return }
                            reader.scrollTo(id, anchor: .bottom)
                        }
                        
                        TextField("Type a message...", text: $viewModel.inputText, axis: .vertical)
                            .lineLimit(1...4)
                            .padding(.horizontal, 6)
                            .padding(.leading, 4)
                            .foregroundColor(.white)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.sentences)
                            .focused($isFocused)
                        
                        Button(action: {
                            impactFeedback.impactOccurred()
                            if !viewModel.isInteracting {
                                if !viewModel.appProvider.hasRequestedReview {
                                    requestReview()
                                    viewModel.appProvider.hasRequestedReview = true
                                    UserDefaults.standard.set(true, forKey: "hasRequestedReview")
                                }
                                
                                if (AppProvider.shared.isUserSubscribed || AppProvider.shared.messagesCount > 0) {
                                    Task {
                                        if !viewModel.inputText.isEmpty {
                                            AppProvider.shared.sendMessage()
                                            await viewModel.sendTapped()
                                            viewModel.scrollToBottom(proxy: reader)
                                        }
                                    }
                                } else {
                                    Superwall.shared.register(event: "campaign_trigger")
                                }
                            } else {
                                viewModel.cancelResponse()
                            }
                        }) {
                            ZStack {
                                Rectangle()
                                    .frame(width: 35, height: 35)
                                    .cornerRadius(17.5)
                                    .foregroundStyle(AppConstants.shared.primaryColor)
                                
                                Image(systemName: viewModel.isInteracting ? "stop.fill" : "paperplane.fill")
                                    .font(.headline)
                                    .foregroundColor(.black.opacity(0.8))
                            }
                            .padding(.trailing, 11)
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
                .onAppear {
                    if !self.prompt.isEmpty {
                        viewModel.inputText = prompt
                    }
                }
            }
            .fullScreenCover(isPresented: $viewModel.isImageViewPresented) {
                ZStack {
                    AppConstants.shared.backgroundColor.edgesIgnoringSafeArea(.all)
                    
                    if let image = viewModel.selectedImageToView {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                    }
                    
                    VStack {
                        HStack {
                            Button(action: {
                                viewModel.isImageViewPresented = false
                                viewModel.selectedImageToView = nil
                            }) {
                                Image(systemName: "xmark")
                                    .foregroundColor(.white)
                                    .font(.title3)
                                    .padding()
                            }
                            
                            Spacer()
                        }
                        
                        Spacer()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Menu {
                        ForEach(Array(model.apiModel.modelsList.keys), id: \.self) { model in
                            Button(action: {
                                viewModel.pickedModel = model
                            }) {
                                HStack {
                                    Text(model)
                                        .font(.subheadline)
                                        .foregroundStyle(.white)
                                    
                                    Spacer()
                                    
                                    if viewModel.pickedModel == model {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.white)
                                            .font(.subheadline)
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(alignment: .center, spacing: 7) {
                            Image(model.avatar)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                                .cornerRadius(12.5)
                            
                            Text(viewModel.pickedModel)
                                .foregroundStyle(.white)
                                .font(.subheadline.bold())
                            
                            Image(systemName: "chevron.forward")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        impactFeedback.impactOccurred()
                        var string = ""
                        
                        viewModel.messages.forEach { message in
                            string += "User: \(message.sendText)"
                            string += "\n"
                            string += "AI: \(message.responseText ?? "Loading...")" + "\n"
                        }
                        
                        viewModel.appProvider.stringToShare = string
                        viewModel.appProvider.isSharing = true
                    }) {
                        Image("share-chat")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                    }
                }
            }
        }
        .background(AppConstants.shared.backgroundColor)
        .preferredColorScheme(.dark)
    }
}
