//
//  VimeoPlayer.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 2/8/25.
//

import SwiftUI
import WebKit
import UIKit
import AVKit
import MediaPlayer

struct VimeoVideoPlayer: View {
    @Environment(LibraryManager.self) var libManager
    let preach: Preach

    @State private var player: AVPlayer?
    @State private var isLoading = true
    @State private var errorMessage: String?

    @State private var showPlayButton: Bool = true
    
    var body: some View {
        ZStack {
            Color.gray
            if let player {
                VideoPlayer(player: player)
                    .aspectRatio(16/9, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .onAppear {
                        player.play()
                        showPlayButton = false
                    }
            } else {
                VStack {
                    if let error = errorMessage {
                        ContentUnavailableView("Error", systemImage: "exclamationmark.triangle.fill", description: Text(error))
                    } else {
                        ProgressView()
                            .tint(.customRed)
                        Text("Preparando video...")
                            .foregroundStyle(.white)
                            .font(.caption)
                    }
                }
            }
            ZStack {
                ThumbImageLoader(storageCollection: .preaches(preach.imageId))
                Image(.halfDottedCirclePlay)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80)
                    .foregroundStyle(.customRed)
            }
            .opacity(showPlayButton ? 1 : 0)
            .onTapGesture {
                withAnimation(.easeOut) {
                    showPlayButton = false
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .task {
            setupAudioSession()
            await loadVideo()
        }
        .enableInjection()
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}
extension VimeoVideoPlayer {
    private func loadVideo() async {
        isLoading = true
        do {
            let url = try await libManager.getValidVideoUrl(for: preach)
            await MainActor.run {
                setupAudioSession()
//                self.player = AVPlayer(url: url)
                let newPlayer = AVPlayer(url: url)
                newPlayer.allowsExternalPlayback = true
                newPlayer.automaticallyWaitsToMinimizeStalling = true
                self.player = newPlayer
                self.isLoading = false
                
                libManager.updateNowPlayingInfo(for: preach, duration: 200)
                setupRemoteCommandCenter()
            }
        } catch {
            print("ERROR: Error cargando video \(error)")
            errorMessage = "No pudimmos conectar con el servidor del video"
            self.isLoading = false
        }
    }
    func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget { event in
            player?.play()
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { event in
            player?.pause()
            return .success
        }
        commandCenter.skipForwardCommand.preferredIntervals = [15]
        commandCenter.skipForwardCommand.addTarget { _ in
            let currentTime = player?.currentTime() ?? .zero
            let newTime = CMTimeAdd(currentTime, CMTime(value: 15, timescale: 1))
            player?.seek(to: newTime)
            return .success
        }
    }
    func setupAudioSession() {
        do {
                // La categoría .playback es la que permite seguir sonando con pantalla bloqueada
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [])
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("Fallo al configurar la sesión de audio: \(error)")
            }
    }
}
