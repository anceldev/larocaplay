//
//  CustomVideoPlayer.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 31/12/25.
//


import AVKit
import AVFoundation
import MediaPlayer
import SwiftUI

struct CustomVideoPlayer: UIViewControllerRepresentable {
    let url: URL
    let title: String
    let artist: String
    
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        let player = AVPlayer(url: url)
        
        controller.player = player
        controller.updatesNowPlayingInfoCenter = true // Lo manejaremos nosotros manualmente
        
        controller.allowsPictureInPicturePlayback = true
        controller.canStartPictureInPictureAutomaticallyFromInline = true
        
        
        // Configurar Audio Session para Background Audio
        setupAudioSession()
        
        // Configurar Controles de Pantalla de Bloqueo
        setupRemoteTransportControls(player: player)
        
        // Configurar Metadatos
        
        // Gestionar Interrupciones (Llamadas, Alarmas)
        setupInterruptionNotification()
        setupMetadata(for: player)
        
        
        updateNowPlayingManual(title: title, artist: artist)
        
        player.play()
        
        return controller
    }
    
    private func updateNowPlayingManual(title: String, artist: String) {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        
        // Si no pones esto, la barra de tiempo no saldrá (porque desactivamos el auto)
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
    
    // MARK: - Lógica Interna
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error configurando Audio Session: \(error)")
        }
    }
    
    private func setupRemoteTransportControls(player: AVPlayer) {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        //--
        commandCenter.playCommand.removeTarget(nil)
        commandCenter.pauseCommand.removeTarget(nil)
        // --
        
        commandCenter.playCommand.addTarget { _ in
            player.play()
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { _ in
            player.pause()
            return .success
        }
    }
    
    private func setupInterruptionNotification() {
        NotificationCenter.default.addObserver(forName: AVAudioSession.interruptionNotification, object: nil, queue: .main) { notification in
            guard let userInfo = notification.userInfo,
                  let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                  let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }
            
            if type == .ended {
                if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                    let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                    if options.contains(.shouldResume) {
                        // Aquí el player debería reanudar si estaba reproduciendo
                    }
                }
            }
        }
    }
    private func setupMetadata(for player: AVPlayer) {
        let titleItem = AVMutableMetadataItem()
        titleItem.identifier = .commonIdentifierTitle
        titleItem.value = title as NSString
        titleItem.extendedLanguageTag = "und"
        
        let artistItem = AVMutableMetadataItem()
        artistItem.identifier = .commonIdentifierArtist
        artistItem.value = artist as NSString
        artistItem.extendedLanguageTag = "und"
        
        let authorItem = AVMutableMetadataItem()
        authorItem.identifier = .commonIdentifierAuthor
        artistItem.value = artist as NSString
        authorItem.extendedLanguageTag = "und"
        
        player.currentItem?.externalMetadata = [titleItem, artistItem]
    }
    
    // Dentro de tu struct CustomVideoPlayer
    static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: Coordinator) {
        if !coordinator.isPiPActive {
            uiViewController.player?.pause()
            uiViewController.player = nil
        }
    }
    class Coordinator: NSObject, AVPlayerViewControllerDelegate {
        var isPiPActive = false
        
        func playerViewControllerWillStartPictureInPicture(_ playerViewController: AVPlayerViewController) {
            isPiPActive = true
        }
        
        func playerViewControllerDidStopPictureInPicture(_ playerViewController: AVPlayerViewController) {
            isPiPActive = false
        }
        
        func playerViewController(_ playerViewController: AVPlayerViewController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
            completionHandler(true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}