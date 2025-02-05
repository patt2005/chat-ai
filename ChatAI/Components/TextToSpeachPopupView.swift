//
//  TextToSpeachPopupView.swift
//  ChatAI
//
//  Created by Petru Grigor on 13.01.2025.
//

import SwiftUI
import AVFoundation
import Combine

struct GenerationVoice: Hashable {
    let name: String
    var audioURL: URL {
        return URL(string: "https://cdn.openai.com/API/docs/audio/\(name).wav")!
    }
}

class TextTOSpeachPopupViewModel: ObservableObject {
    @Published var selectedVoice: GenerationVoice = GenerationVoice(name: "alloy")
    
    private var audioPlayer: AVPlayer?
    private var playbackTimer: Timer?

    private var cancellables = Set<AnyCancellable>()
    
    func playAudio(url: URL) {
        if let player = audioPlayer, player.timeControlStatus == .playing {
            player.pause()
        }
        
        let playerItem = AVPlayerItem(url: url)
        audioPlayer = AVPlayer(playerItem: playerItem)
        
        audioPlayer?.play()
        
        playbackTimer?.invalidate()
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 3.5, repeats: false) { _ in
            self.audioPlayer?.pause()
        }
    }
    
    init() {
        $selectedVoice
            .dropFirst()
            .sink { voice in
                self.playAudio(url: voice.audioURL)
            }
            .store(in: &cancellables)
    }
}

struct TextToSpeachPopupView: View {
    @Binding var isPresented: Bool
    @Binding var isLoading: Bool
    @Binding var showError: Bool
    
    @State private var inputText: String = ""
    
    let voices: [GenerationVoice] = [GenerationVoice(name: "alloy"), GenerationVoice(name: "ash"), GenerationVoice(name: "coral"), GenerationVoice(name: "echo"), GenerationVoice(name: "fable"), GenerationVoice(name: "onyx"), GenerationVoice(name: "nova"), GenerationVoice(name:  "sage"), GenerationVoice(name: "shimmer")
    ]
    
    @ObservedObject private var appProvider = AppProvider.shared
    
    @StateObject private var viewModel = TextTOSpeachPopupViewModel()
    
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
                
                VStack(spacing: 15) {
                    HStack {
                        Text("Text to Speech")
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
                    
                    TextField("Enter text to convert to speech", text: $inputText)
                        .padding(.leading, 28)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        .overlay(
                            HStack {
                                Image(systemName: "textformat.alt")
                                    .foregroundColor(.gray)
                                    .padding(.leading, 10)
                                Spacer()
                            }
                        )
                    
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(voices, id: \.name) { voice in
                                Button(action: {
                                    viewModel.selectedVoice = voice
                                }) {
                                    HStack {
                                        Text(voice.name)
                                            .font(.body)
                                            .padding(.leading, 5)
                                            .foregroundStyle(.white)
                                        
                                        if viewModel.selectedVoice.name == voice.name {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                        }
                                        
                                        Rectangle()
                                            .frame(maxWidth: .infinity)
                                            .foregroundStyle(.clear)
                                        
                                        Button(action: {
                                            viewModel.playAudio(url: voice.audioURL)
                                        }) {
                                            Image(systemName: "play.circle.fill")
                                                .foregroundColor(AppConstants.shared.primaryColor)
                                                .font(.title2)
                                        }
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(viewModel.selectedVoice.name == voice.name ? Color.blue.opacity(0.2) : Color.clear)
                                    .cornerRadius(10)
                                }
                            }
                        }
                    }
                    .frame(height: 172)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                    
                    Text("Convert text to speech using the selected voice.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        guard !inputText.isEmpty else { return }
                        
                        withAnimation {
                            isPresented = false
                            isLoading = true
                        }
                        
                        Task {
                            do {
                                let audioFile = try await OpenAiApi().generateSpeach(inputText, voice: viewModel.selectedVoice.name)
                                
                                appProvider.navigationPath.append(.speachDetailsView(audioFilePath: audioFile))
                            } catch {
                                showError = true
                            }
                            
                            isLoading = false
                            inputText = ""
                        }
                    }) {
                        Text("Generate Speech")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(inputText.isEmpty ? Color.gray : AppConstants.shared.primaryColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .opacity(inputText.isEmpty ? 0.5 : 1.0)
                    }
                    .disabled(inputText.isEmpty)
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
