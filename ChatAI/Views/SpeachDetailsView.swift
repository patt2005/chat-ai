//
//  SpeachDetailsView.swift
//  ChatAI
//
//  Created by Petru Grigor on 13.01.2025.
//

import SwiftUI
import AVFoundation
import UIKit

class AudioPlayerManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isPlaying: Bool = false
    
    private var audioPlayer: AVAudioPlayer?
    
    func playAudio(filePath: String) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
            
            if let audioPlayer = audioPlayer {
                audioPlayer.play()
                isPlaying = true
            } else {
                let fileURL = URL(fileURLWithPath: filePath)
                audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
                audioPlayer?.delegate = self
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
                isPlaying = true
            }
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }
}

struct SpeachDetailsView: View {
    @StateObject private var audioManager = AudioPlayerManager()
    
    let audioFilepath: String
    
    init(audioFilePath: String) {
        self.audioFilepath = audioFilePath
    }
    
    private func shareAudio() {
        let fileURL = URL(fileURLWithPath: audioFilepath)
        let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    private func downloadAudio() {
        let fileURL = URL(fileURLWithPath: audioFilepath)

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("File not found at path: \(fileURL.path)")
            return
        }
        
        let tempDestination = FileManager.default.temporaryDirectory.appendingPathComponent("DownloadedAudio.mp3")
        do {
            if FileManager.default.fileExists(atPath: tempDestination.path) {
                try FileManager.default.removeItem(at: tempDestination)
            }
            
            try FileManager.default.copyItem(at: fileURL, to: tempDestination)
        } catch {
            print("Error preparing file for download: \(error.localizedDescription)")
            return
        }
        
        let documentPicker = UIDocumentPickerViewController(forExporting: [tempDestination])
        documentPicker.delegate = UIApplication.shared.windows.first?.rootViewController as? UIDocumentPickerDelegate
        documentPicker.allowsMultipleSelection = false
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.first?.rootViewController?.present(documentPicker, animated: true, completion: nil)
        }
    }
    
    var body: some View {
        ZStack {
            AppConstants.shared.backgroundColor
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                Text("Enjoy Your Audio")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                Text(audioManager.isPlaying ? "Playing Audio" : "Tap Play to Start")
                    .foregroundColor(.gray)
                    .font(.subheadline)
                    .padding(.top, 10)
                
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 125, height: 125)
                        .shadow(radius: 10)
                    
                    Button(action: {
                        audioManager.playAudio(filePath: audioFilepath)
                    }) {
                        Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.top, 50)
                
                Button(action: {
                    shareAudio()
                }) {
                    HStack(alignment: .center) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 25))
                            .foregroundColor(.black)
                            .padding(.bottom, 3)
                        Text("Share")
                            .foregroundColor(.black)
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(AppConstants.shared.primaryColor)
                    .cornerRadius(15)
                    .padding(.horizontal, 18)
                }
                .padding(.top, 100)
                
                Button(action: {
                    downloadAudio()
                }) {
                    HStack {
                        Image(systemName: "arrow.down.circle")
                            .font(.system(size: 25))
                            .foregroundColor(.black)
                        Text("Download")
                            .foregroundColor(.black)
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(AppConstants.shared.primaryColor)
                    .cornerRadius(15)
                    .padding(.horizontal, 18)
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .padding()
        }
    }
}
