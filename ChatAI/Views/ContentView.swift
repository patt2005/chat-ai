//
//  ContentView.swift
//  ChatAI
//
//  Created by Petru Grigor on 26.12.2024.
//

import SwiftUI
import Combine
import SuperwallKit

class ContentViewModel: ObservableObject {
    @Published var selectedTab = 0
    
    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        if AppProvider.shared.isFirstOpen {
            Superwall.shared.register(event: "onboarding_trigger")
            AppProvider.shared.completeOnboarding()
        }
        
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(Color(hex: "#19191b"))
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemMaterialDark)
        appearance.backgroundColor = UIColor(AppConstants.shared.backgroundColor)
        appearance.shadowColor = nil
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        
        self.impactFeedback.prepare()
        
        $selectedTab
            .sink { newTab in
                self.impactFeedback.impactOccurred()
            }
            .store(in: &cancellables)
    }
}

struct ContentView: View {
    @ObservedObject private var appProvider = AppProvider.shared
    
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        ZStack {
            NavigationStack(path: $appProvider.navigationPath) {
                TabView(selection: $viewModel.selectedTab) {
                    HomeView()
                        .tabItem { Label("Chat", systemImage: "ellipsis.message" ) }.tag(0)
                    
                    HistoryView()
                        .tabItem { Label("History", systemImage: "clock.arrow.circlepath") }.tag(1)
                    
                    SettingsView()
                        .tabItem { Label("Settings", systemImage: "gearshape") }.tag(2)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        HStack(alignment: .center, spacing: 5) {
                            Image("icon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .cornerRadius(20)
                            
                            Text(appProvider.appName)
                                .font(.title2.bold())
                                .foregroundStyle(.white)
                                .opacity(appProvider.opacity)
                                .animation(.easeInOut(duration: 0.5), value: appProvider.opacity)
                        }
                    }
                    
                    if (!appProvider.isUserSubscribed) {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: {
                                Superwall.shared.register(event: "campaign_trigger")
                            }) {
                                HStack(spacing: 5) {
                                    Image(systemName: "crown.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundStyle(.black)
                                        .frame(width: 25, height: 25)
                                    
                                    Text("PRO")
                                        .foregroundStyle(.black)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 7)
                                .background(AppConstants.shared.primaryColor)
                                .cornerRadius(10)
                            }
                        }
                    }
                }
                .sheet(isPresented: $appProvider.isSharing) {
                    ActivityView(activityItems: [appProvider.stringToShare])
                }
                .navigationDestination(for: NavigationDestination.self) { destination in
                    switch destination {
                    case .chatView(let prompt, let model, let history): ChatView(prompt: prompt, model: model, chatHistory:  history)
                    case .summaryView(let text): TextSummaryView(text: text)
                    case .imageDataView(let image, let style, let ratio): ImageDataView(image: image, aspectRatio: ratio, style: style)
                    case .speachDetailsView(let filePath) : SpeachDetailsView(audioFilePath: filePath)
                    case .restoreView : RestoreView()
                    case .manageSubscriptionView : ManageSubscriptionView()
                    case .chatPdfView(let pdfData) : ChatPdfView(pdfData: pdfData)
                    }
                }
            }
            
            if appProvider.isLoading || appProvider.showBlurOverlay {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
            }
            
            if appProvider.isLoading {
                VStack {
                    Text("Loading...")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                }
            }
            
            SummaryPopupView(isPresented: $appProvider.showSummaryPopup, isLoading: $appProvider.isLoading, showError: $appProvider.showErrorAlert)
            
            ImageGenerationPopupView(isPresented: $appProvider.showImagePopup, isLoading: $appProvider.isLoading, showError: $appProvider.showErrorAlert)
            
            PDFPopupView(isPresented: $appProvider.showPDFPopup, showError: $appProvider.showErrorAlert)
            
            TextToSpeachPopupView(isPresented: $appProvider.showTextToSpeachPopup, isLoading: $appProvider.isLoading, showError: $appProvider.showErrorAlert)
            
            FeaturePreviewPopupView(isPresented: $appProvider.showPreviwInfoPopup, previewInfo: appProvider.selectedPreview ?? featuresPreview[0])
        }
        .preferredColorScheme(.dark)
    }
}
