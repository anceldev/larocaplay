//
//  MusicScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 12/10/25.
//

import SwiftUI
import AVKit

struct MusicScreen: View {
//    @State private var musicRepository = MusicRepository()
    @Environment(MusicVideoRepository.self) var musicVideoRepository
    @State private var isPlayed: Int? = nil
    
//    var itemPlayed: MusicItem? {
//        if let isPlayed {
//            return musicRepository.music.first { $0.id == isPlayed }
//        }
//        return nil
//    }
    var body: some View {
        VStack(spacing: 16) {
            Text("Lista de canciones")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
//            if let itemPlayed {
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Reproduciendo:")
//                        .font(.system(size: 14, weight: .semibold))
//                        .foregroundStyle(.dirtyWhite)
//                    HStack {
//                        Text(itemPlayed.name)
//                            .font(.system(size: 20, weight: .semibold))
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                    }
//                }
//                .frame(maxWidth: .infinity)
//            }
            ScrollView(.vertical) {
                if musicVideoRepository.songs.count > 0 {
                    VStack(spacing: 32) {
                        ForEach(musicVideoRepository.songs) { song in
                                VStack {
                                    YoutubeEmbedView(videoID: song.videoUrl, playlistID: nil)
                                        .frame(height: 220)
                                        .cornerRadius(12)
                                        .shadow(radius: 4)
                                }
                                .border(.green, width: 1)
                            
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(.customBlack)
        .enableInjection()
    }
    private func extractYouTubeID(from url: String) -> String? {
        // Caso 1: URLs tipo https://youtu.be/VIDEOID
        if url.contains("youtu.be") {
            return url.split(separator: "/").last?
                .split(separator: "?").first.map(String.init)
        }

        // Caso 2: URLs tipo https://www.youtube.com/watch?v=VIDEOID
        if let queryItems = URLComponents(string: url)?.queryItems {
            return queryItems.first(where: { $0.name == "v" })?.value
        }

        return nil
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}

#Preview {
    MusicScreen()
}
