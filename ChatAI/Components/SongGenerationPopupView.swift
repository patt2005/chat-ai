////
////  SongGenerationPopupView.swift
////  ChatAI
////
////  Created by Petru Grigor on 02.01.2025.
////
//
//import SwiftUI
//
//struct SongGenerationPopupView: View {
//    @Binding var isPresented: Bool
//    @Binding var isLoading: Bool
//    @Binding var showError: Bool
//    
//    @State private var songTitle: String = ""
//    @State private var songPrompt: String = ""
//    @State private var songStyle: String = ""
//    
//    @ObservedObject private var appProvider = AppProvider.shared
//    
//    var body: some View {
//        ZStack {
//            if isPresented {
//                Color.black.opacity(0.4)
//                    .edgesIgnoringSafeArea(.all)
//                    .onTapGesture {
//                        withAnimation {
//                            isPresented = false
//                        }
//                    }
//                    .transition(.opacity)
//                
//                VStack(spacing: 20) {
//                    HStack {
//                        Text("Generate a Song")
//                            .font(.headline)
//                            .fontWeight(.bold)
//                        Spacer()
//                        Button(action: {
//                            withAnimation {
//                                isPresented = false
//                            }
//                        }) {
//                            Image(systemName: "xmark")
//                                .foregroundColor(.gray)
//                        }
//                    }
//                    
//                    TextField("Enter song title", text: $songTitle)
//                        .padding(.leading, 25)
//                        .padding()
//                        .background(Color(.secondarySystemBackground))
//                        .cornerRadius(10)
//                        .overlay(
//                            HStack {
//                                Image(systemName: "music.note")
//                                    .foregroundColor(.gray)
//                                    .padding(.leading, 10)
//                                Spacer()
//                            }
//                        )
//                    
//                    TextField("Enter song style", text: $songStyle)
//                        .padding(.leading, 25)
//                        .padding()
//                        .background(Color(.secondarySystemBackground))
//                        .cornerRadius(10)
//                        .overlay(
//                            HStack {
//                                Image(systemName: "music.note.list")
//                                    .foregroundColor(.gray)
//                                    .padding(.leading, 10)
//                                Spacer()
//                            }
//                        )
//                    
//                    TextField("Describe the song (prompt)", text: $songPrompt)
//                        .padding(.leading, 25)
//                        .padding()
//                        .background(Color(.secondarySystemBackground))
//                        .cornerRadius(10)
//                        .overlay(
//                            HStack {
//                                Image(systemName: "text.alignleft")
//                                    .foregroundColor(.gray)
//                                    .padding(.leading, 10)
//                                Spacer()
//                            }
//                        )
//                    
//                    Text("Provide a title and a description to generate a song.")
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                    
//                    Button(action: {
//                        guard !songTitle.isEmpty, !songPrompt.isEmpty else { return }
//                        
//                        withAnimation {
//                            isPresented = false
//                            isLoading = true
//                        }
//                        
//                        Task {
//                            do {
//                                let generatedSong = try await SunoAiApi().generateSong(for: songPrompt, title: songTitle, style: songStyle)
//                                isLoading = false
//                                songTitle = ""
//                                songPrompt = ""
//                                
////                                appProvider.navigationPath.append(.songResultView(song: generatedSong))
//                            } catch {
//                                isLoading = false
//                                showError = true
//                            }
//                        }
//                    }) {
//                        Text("Generate")
//                            .font(.headline)
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(songTitle.isEmpty || songPrompt.isEmpty ? Color.gray : AppConstants.shared.primaryColor)
//                            .foregroundColor(.white)
//                            .cornerRadius(10)
//                            .opacity(songTitle.isEmpty || songPrompt.isEmpty ? 0.5 : 1.0)
//                    }
//                    .disabled(songTitle.isEmpty || songPrompt.isEmpty || songStyle.isEmpty)
//                }
//                .transition(.opacity)
//                .padding()
//                .frame(maxWidth: .infinity)
//                .background(Color(.systemBackground))
//                .cornerRadius(20)
//                .padding(.horizontal, 30)
//                .transition(.move(edge: .bottom))
//                .zIndex(1)
//            }
//        }
//    }
//}
