//
//  HomeView.swift
//  ChatAI
//
//  Created by Petru Grigor on 26.12.2024.
//

import SwiftUI
import SuperwallKit

struct HomeView: View {
    struct PremiumFeature {
        let title: String
        let image: String
        let description: String
        let action: () -> Void
    }
    
    struct IdeaInfo {
        let title: String
        let image: String
        let prompt: String
    }
    
    @ObservedObject private var appProvider = AppProvider.shared
    
    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    @State private var showSummaryPopup = false
    @State private var showImagePopup = false
    @State private var showPDFPopup = false
    @State private var showTextToSpeachPopup = false
    
    @State private var showErrorAlert = false
    @State private var isLoading = false
    
    @Environment(\.requestReview) var requestReview
    
    private let ideaInfoList: [IdeaInfo] = [
        IdeaInfo(
            title: "Plan a Dream Vacation",
            image: "airplane.circle.fill",
            prompt: "Help me plan a dream vacation to Japan with a detailed 7-day itinerary."
        ),
        IdeaInfo(
            title: "Startup Pitch",
            image: "lightbulb.fill",
            prompt: "Create a 2-minute elevator pitch for a startup that connects pet owners with local pet sitters."
        ),
        IdeaInfo(
            title: "Healthy Recipes",
            image: "leaf.fill",
            prompt: "Suggest 5 quick and healthy dinner recipes under 30 minutes."
        ),
        IdeaInfo(
            title: "Workout Routine",
            image: "figure.walk",
            prompt: "Generate a beginner-friendly 4-week workout plan to build strength and endurance."
        ),
        IdeaInfo(
            title: "Learn a New Skill",
            image: "book.fill",
            prompt: "Provide a step-by-step guide for learning how to play the guitar as a complete beginner."
        ),
        IdeaInfo(
            title: "Social Media Caption",
            image: "camera.fill",
            prompt: "Create a catchy Instagram caption for a sunset photo at the beach."
        )
    ]
    
    @State private var premiumFeatures: [PremiumFeature] = [
        //        PremiumFeature(title: "Music generation", image: "t-m", description: "Create music with text"),
    ]
    
    private let assistantsList: [AssistantModel] = [
        AssistantModel(name: "Qwen", avatar: "qwen", apiModel: QwenApi.shared, type: .qwen),
        AssistantModel(name: "DeepSeek", avatar: "deepseek", apiModel: DeepSeekApi.shared, type: .deepSeek),
        AssistantModel(name: "ChatGPT", avatar: "chatgpt", apiModel: OpenAiApi.shared, type: .openAi),
        AssistantModel(name: "Claude AI", avatar: "claude", apiModel: ClaudeAiApi.shared, type: .claudeAi),
        AssistantModel(name: "Gemini", avatar: "gemini", apiModel: GeminiAiApi.shared, type: .gemini),
        AssistantModel(name: "Meta AI", avatar: "meta", apiModel: MetaAiApi.shared, type: .metaAi),
    ]
    
    private let popularPrompts: [String] = [
        "Explain blockchain technology in simple terms.",
        "Write a creative story about a futuristic world where memes control the economy.",
        "What are the top investment tips for 2025?",
        "Summarize the latest news about cryptocurrency in under 50 words.",
        "Generate a funny meme caption for a picture of a cat holding a laptop.",
        "Provide a step-by-step guide to start trading meme coins.",
        "What are the potential risks and rewards of investing in meme coins?"
    ]
    
    private func featureCard(featureInfo: PremiumFeature) -> some View {
        VStack(spacing: 0) {
            Image(featureInfo.image)
                .resizable()
                .scaledToFit()
                .frame(height: 60)
            
            VStack(alignment: .center, spacing: 10) {
                Text(featureInfo.title)
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                
                Text(featureInfo.description)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            .padding(.horizontal)
            .padding(.bottom, 15)
        }
        .frame(width: 150)
        .background(AppConstants.shared.grayColor)
        .cornerRadius(15)
    }
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    Text("Assistants 🤖")
                        .font(.title2.bold())
                        .padding(.top, 15)
                        .padding(.horizontal, 19)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            Rectangle()
                                .foregroundStyle(.clear)
                                .frame(width: 6)
                            
                            ForEach(assistantsList, id: \.name) { assistant in
                                Button(action: {
                                    impactFeedback.impactOccurred()
                                    appProvider.navigationPath.append(.chatView(model: assistant))
                                }) {
                                    VStack(spacing: 10) {
                                        Image(assistant.avatar)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                        
                                        Text(assistant.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                    }
                                    .frame(width: 140, height: 105)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                            .background(
                                                RoundedRectangle(cornerRadius: 15)
                                                    .fill(Color(.systemBackground))
                                            )
                                    )
                                    .padding(.vertical, 1)
                                }
                            }
                            
                            Rectangle()
                                .foregroundStyle(.clear)
                                .frame(width: 12)
                        }
                    }
                    
                    Text("Premium features 👑")
                        .font(.title2.bold())
                        .padding(.top, 15)
                        .padding(.horizontal, 19)
                        .onAppear {
                            if (premiumFeatures.isEmpty) {
                                premiumFeatures.append(contentsOf: [
                                    PremiumFeature(title: "Image generation", image: "t-i", description: "Create images with prompts", action: { showImagePopup = true }),
                                    PremiumFeature(title: "YouTube summary", image: "y-t", description: "Summarize text from a video", action: { showSummaryPopup = true }),
                                    PremiumFeature(title: "PDF summary", image: "p-t", description: "Summarize text from a PDF", action: { showPDFPopup = true }),
                                    PremiumFeature(title: "Text to Speech", image: "t-s", description: "Convert text into audio speech", action: { showTextToSpeachPopup = true }),
                                ])
                            }
                        }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            Rectangle()
                                .foregroundStyle(.clear)
                                .frame(width: 13)
                            
                            ForEach(premiumFeatures, id: \.title) { feature in
                                Button(action: {
                                    impactFeedback.impactOccurred()
                                    if (!appProvider.isUserSubscribed) {
                                        Superwall.shared.register(event: "campaign_trigger")
                                    } else {
                                        withAnimation {
                                            feature.action()
                                        }
                                    }
                                }) {
                                    featureCard(featureInfo: feature)
                                }
                            }
                            
                            Rectangle()
                                .foregroundStyle(.clear)
                                .frame(width: 13)
                        }
                    }
                    
                    Text("Popular prompts 🔥")
                        .font(.title2.bold())
                        .padding(.top, 15)
                        .padding(.horizontal, 19)
                        .onAppear {
                            if appProvider.isFirstOpen {
                                requestReview()
                            }
                        }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            Rectangle()
                                .foregroundStyle(.clear)
                                .frame(width: 12)
                            
                            ForEach(popularPrompts, id: \.self) { prompt in
                                Button(action: {
                                    impactFeedback.impactOccurred()
                                    appProvider.navigationPath.append(.chatView(prompt))
                                }) {
                                    VStack(alignment: .leading, spacing: 10) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "lightbulb")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 20, height: 20)
                                                .foregroundColor(.white)
                                            Text("Popular Prompt")
                                                .font(.caption)
                                                .foregroundStyle(.white)
                                        }
                                        
                                        Text(prompt)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(3)
                                    }
                                    .padding()
                                    .frame(width: 170, height: 120)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                            .background(
                                                RoundedRectangle(cornerRadius: 15)
                                                    .fill(Color(.systemBackground))
                                            )
                                    )
                                    .shadow(color: AppConstants.shared.grayColor.opacity(0.2), radius: 4, x: 0, y: 2)
                                    .padding(.vertical, 1)
                                }
                            }
                            
                            Rectangle()
                                .foregroundStyle(.clear)
                                .frame(width: 12)
                        }
                    }
                    
                    Text("Some ideas to get\nyou started 💡")
                        .font(.title2.bold())
                        .padding(.top, 15)
                        .padding(.horizontal, 19)
                        .onAppear {
                            impactFeedback.prepare()
                        }
                    
                    VStack {
                        ForEach(ideaInfoList, id: \.title) { idea in
                            Button(action: {
                                impactFeedback.impactOccurred()
                                appProvider.navigationPath.append(.chatView(idea.prompt))
                            }) {
                                HStack(alignment: .top, spacing: 15) {
                                    Image(systemName: idea.image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.accentColor)
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(idea.title)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        Text(idea.prompt)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .lineLimit(2)
                                            .multilineTextAlignment(.leading)
                                    }
                                    Spacer()
                                }
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.bottom)
                    .padding(.horizontal, 19)
                }
                .frame(maxWidth: .infinity)
            }
            .background(AppConstants.shared.backgroundColor)
            .preferredColorScheme(.dark)
            .blur(radius: isLoading ? 4 : 0)
            .alert("Error", isPresented: $showErrorAlert, actions: {
                Button("OK", role: .cancel) {}
            }, message: {
                Text("There was an error. Please try again later.")
            })
            
            SummaryPopupView(isPresented: $showSummaryPopup, isLoading: $isLoading, showError: $showErrorAlert)
            
            ImageGenerationPopupView(isPresented: $showImagePopup, isLoading: $isLoading, showError: $showErrorAlert)
            
            PDFPopupView(isPresented: $showPDFPopup, isLoading: $isLoading, showError: $showErrorAlert)
            
            TextToSpeachPopupView(isPresented: $showTextToSpeachPopup, isLoading: $isLoading, showError: $showErrorAlert)
            
            if isLoading {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Loading...")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                }
            }
        }
    }
}
