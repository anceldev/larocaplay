//
//  NewVideoPlayer.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 30/12/25.
//

import SwiftUI
import AVKit
import MediaPlayer

import AVFoundation

//@Observable
//class PlayerManager {
//    var player: AVPlayer?
//        
//        func prepare(url: URL, title: String) {
//            // 1. Configurar AudioSession (Crucial para bloqueo)
//            let session = AVAudioSession.sharedInstance()
//            try? session.setCategory(.playback, mode: .moviePlayback, options: [.allowAirPlay])
//            try? session.setActive(true)
//            
//            // 2. Crear Player
//            let player = AVPlayer(url: url)
//            // .automatic es la clave para el segundo plano
//            player.audiovisualBackgroundPlaybackPolicy = .automatic
//            player.allowsExternalPlayback = true
//            
//            self.player = player
//            
//            // 3. Controles en pantalla de bloqueo
//            setupMetadata(title: title)
//        }
//        
//        private func setupMetadata(title: String) {
//            let center = MPNowPlayingInfoCenter.default()
//            center.nowPlayingInfo = [MPMediaItemPropertyTitle: title]
//            
//            let remote = MPRemoteCommandCenter.shared()
//            remote.playCommand.addTarget { [weak self] _ in self?.player?.play(); return .success }
//            remote.pauseCommand.addTarget { [weak self] _ in self?.player?.pause(); return .success }
//        }
//}
//
//
//struct VersatileVideoPlayer: UIViewControllerRepresentable {
//    let player: AVPlayer
//        
//        func makeUIViewController(context: Context) -> AVPlayerViewController {
//            let controller = AVPlayerViewController()
//            controller.player = player
//            
//            // Permite que el vídeo siga si sales de la app (PiP)
//            controller.allowsPictureInPicturePlayback = true
//            controller.canStartPictureInPictureAutomaticallyFromInline = true
//            
//            // IMPORTANTE: Esto sincroniza los controles nativos con la pantalla de bloqueo
//            controller.updatesNowPlayingInfoCenter = true
//            
//            return controller
//        }
//        
//        func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
//        
//        // Al salir de la vista (dar atrás), pausamos el vídeo
////        static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: ()) {
////            uiViewController.player?.pause()
////        }
//}
