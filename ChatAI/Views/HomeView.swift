//
//  HomeView.swift
//  ChatAI
//
//  Created by Petru Grigor on 26.12.2024.
//

import SwiftUI
import SuperwallKit

struct FeaturePreviewInfo {
    let features: [Feature]
}

struct Feature {
    let text: String
    let image: String
}

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
    
    struct AppInfo {
        let name: String
        let image: String
        let description: String
        let appUrl: String
    }
    
    @ObservedObject private var appProvider = AppProvider.shared
    
    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    
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
    
    @State private var premiumFeatures: [PremiumFeature] = []
    
    private let assistantsList: [AssistantModel] = [
        AssistantModel(name: "Grok", avatar: "grok", apiModel: GrokAiApi.shared, type: .grok),
        AssistantModel(name: "Qwen", avatar: "qwen", apiModel: QwenApi.shared, type: .qwen),
        AssistantModel(name: "ChatGPT", avatar: "chatgpt", apiModel: OpenAiApi.shared, type: .openAi),
        AssistantModel(name: "Claude AI", avatar: "claude", apiModel: ClaudeAiApi.shared, type: .claudeAi),
        AssistantModel(name: "Gemini", avatar: "gemini", apiModel: GeminiAiApi.shared, type: .gemini),
    ]
    
    private let otherAiApps: [AppInfo] = [
        AppInfo(name: "Meme AI", image: "meme-ai", description: "Track trending meme coins in real-time with AI-powered insights, price alerts, and market analysis", appUrl: "https://apps.apple.com/us/app/meme-coin-tracker-dex-screener/id6738891806"),
        AppInfo(name: "Motivation AI", image: "motivation", description: "Stay inspired every day with personalized AI-generated motivational quotes and life-changing affirmations", appUrl: "https://apps.apple.com/us/app/motivation-stoic-daily-quotes/id6740817263"),
        AppInfo(name: "Learn AI", image: "learn-ai", description: "An interactive AI-powered educational app designed for kids to learn coding, problem-solving, and critical thinking", appUrl: "https://apps.apple.com/us/app/learnai-%C3%AEnva%C8%9B%C4%83-limba-rom%C3%A2n%C4%83/id6738118898"),
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
    
    private func appInfoCard(info: AppInfo) -> some View {
        Link(destination: URL(string: info.appUrl)!) {
            VStack(spacing: 10) {
                Image(info.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                    .padding(.top, 5)
                
                VStack(alignment: .center, spacing: 6) {
                    Text(info.name)
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                    
                    Text(info.description)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.gray)
                        .padding(.horizontal, 10)
                        .lineLimit(4)
                }
                .padding(.bottom, 12)
            }
            .frame(width: 180)
            .background(AppConstants.shared.grayColor)
            .cornerRadius(15)
            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
    
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
                if !appProvider.isUserSubscribed {
                    VStack(spacing: 8) {
                        if appProvider.messagesCount == 0 {
                            VStack(spacing: 8) {
                                Text("Daily Limit Reached 🚀")
                                    .font(.title3.bold())
                                    .foregroundStyle(.white)
                                
                                Text("You've used all \(appProvider.maxDailyMessages) free messages for today. Subscribe to Pro for unlimited access!")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 10)
                                
                                Button(action: {
                                    Superwall.shared.register(event: "campaign_trigger")
                                }) {
                                    Text("Upgrade to Pro")
                                        .font(.subheadline.bold())
                                        .foregroundStyle(.black)
                                        .padding(.vertical, 12)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.white)
                                        .cornerRadius(12)
                                }
                                .padding(.horizontal, 15)
                            }
                        } else {
                            Text("Free Messages Left Today")
                                .font(.title3.bold())
                                .foregroundStyle(.white)
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white.opacity(0.2))
                                        .frame(height: 8)
                                    
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(appProvider.messagesCount > 0 ? Color.green : Color.red)
                                        .frame(width: geometry.size.width * CGFloat(appProvider.messagesCount) / CGFloat(appProvider.maxDailyMessages), height: 8)
                                }
                            }
                            .frame(height: 8)
                            
                            Text("\(appProvider.messagesCount) of \(appProvider.maxDailyMessages) messages remaining")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        AppConstants.shared.grayColor
                    )
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                    .padding(.horizontal, 19)
                    .padding(.top, 15)
                }
                
                VStack(alignment: .leading) {
                    Text("Assistants 🤖")
                        .font(.title2.bold())
                        .padding(.top, 8)
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
                                    PremiumFeature(title: "Image generation", image: "t-i", description: "Create images with prompts", action: { appProvider.showBlurOverlay = true; appProvider.showImagePopup = true }),
                                    PremiumFeature(title: "YouTube summary", image: "y-t", description: "Summarize text from a video", action: { appProvider.showBlurOverlay = true; appProvider.showSummaryPopup = true }),
                                    PremiumFeature(title: "Chat with PDF", image: "p-t", description: "Ask questions about PDF", action: { appProvider.showBlurOverlay = true; appProvider.showPDFPopup = true }),
                                    PremiumFeature(title: "Text to Speech", image: "t-s", description: "Convert text into audio speech", action: { appProvider.showBlurOverlay = true; appProvider.showTextToSpeachPopup = true }),
                                ])
                            }
                        }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            Rectangle()
                                .foregroundStyle(.clear)
                                .frame(width: 13)
                            
                            ForEach(premiumFeatures.indices, id: \.self) { index in
                                Button(action: {
                                    impactFeedback.impactOccurred()
                                    withAnimation {
                                        if appProvider.isUserSubscribed {
                                            premiumFeatures[index].action()
                                        } else {
                                            appProvider.selectedPreview = featuresPreview[index]
                                            appProvider.showPreviwInfoPopup = true
                                            appProvider.showBlurOverlay = true
                                        }
                                    }
                                }) {
                                    featureCard(featureInfo: premiumFeatures[index])
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
                    
                    Text("Other AI tools you\nmight like ⚙️")
                        .font(.title2.bold())
                        .padding(.top, 15)
                        .padding(.horizontal, 19)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            Rectangle()
                                .foregroundStyle(.clear)
                                .frame(width: 12)
                            
                            ForEach(otherAiApps, id: \.name) { info in
                                appInfoCard(info: info)
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
            .blur(radius: appProvider.isLoading ? 4 : 0)
            .alert("Error", isPresented: $appProvider.showErrorAlert, actions: {
                Button("OK", role: .cancel) {}
            }, message: {
                Text("There was an error. Please try again later.")
            })
        }
    }
}
