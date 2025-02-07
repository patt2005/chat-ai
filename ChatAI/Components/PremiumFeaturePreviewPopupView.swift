//
//  PremiumFeaturePreviewPopupView.swift
//  ChatAI
//
//  Created by Petru Grigor on 07.02.2025.
//

import SwiftUI
import SuperwallKit

struct FeaturePreviewPopupView: View {
    @Binding var isPresented: Bool
    
    let previewInfo: FeaturePreviewInfo
    @State private var selectedIndex: Int = 0
    
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
                
                VStack(spacing: 7) {
                    HStack {
                        Text("Unlock Premium Features")
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
                        .onAppear {
                            selectedIndex = 0
                        }
                    }
                    
                    TabView(selection: $selectedIndex) {
                        ForEach(previewInfo.features.indices, id: \.self) { index in
                            VStack(spacing: 15) {
                                Image(previewInfo.features[index].image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                                    .cornerRadius(7)
                                
                                Text(previewInfo.features[index].text)
                                    .font(.body)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                                    .padding(.bottom)
                            }
                            .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .frame(height: 330)
                    
                    Button(action: {
                        Superwall.shared.register(event: "campaign_trigger")
                    }) {
                        Text("Unlock Pro")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppConstants.shared.primaryColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
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
