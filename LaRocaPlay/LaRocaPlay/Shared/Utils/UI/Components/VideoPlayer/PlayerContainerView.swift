//
//  PlayerContainerView.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 31/12/25.
//

import SwiftUI

struct PlayerContainerView: View {
    let title: String
    let artist: String?
    let videoURL: URL
    
    init(title: String, artist: String? = nil, videoURL: URL) {
        self.title = title
        self.artist = artist
        self.videoURL = videoURL
    }
    
    var body: some View {
        VStack {
            // TODO: Añadir el artista o autor. Actualmente solo se ve el título
            CustomVideoPlayer(
                url: videoURL,
                title: title,
                artist: artist ?? "Centro Cristiano La Roca"
            )
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .aspectRatio(16/9, contentMode: .fit)
            .overlay(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.7), // Brillo fuerte superior
                                .white.opacity(0.5), // Lados sutiles
                                .white.opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ).opacity(0.2),
                        lineWidth: 1
                    )
            )
            .background(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 15)
            )
            .padding()
            
            Spacer()
        }
    }
}
