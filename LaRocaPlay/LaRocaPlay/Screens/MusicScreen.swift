//
//  MusicScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 12/10/25.
//

import SwiftUI
import AVKit

struct MusicScreen: View {
//    @Environment(MusicVideoRepository.self) var musicVideoRepository
    @State private var isPlayed: Int? = nil
    //    @State private var videoURL: URL? = nil
    
    var body: some View {
        //        VStack {
        //            if let videoURL {
        //                Text(videoURL.absoluteString)
        //                    .foregroundStyle(.white)
        //                VideoPlayer(player: AVPlayer(url: videoURL))
        //                    .frame(height: 300)
        //            }
        //        }
        //        .onAppear {
        //            loadURL(for: "1146688207")
        //        }
        //    }
        //    private func loadURL(for videoId: String) {
        //        Task {
        //            do {
        ////                self.videoURL = try await VimeoService.shared.loadVideo(for: videoId)
        //                self.videoURL = try await VimeoService.shared.getVideoURL(for: "1146688207")
        //            } catch {
        //                print(error.localizedDescription)
        //            }
        //        }
        //    }
        VStack(spacing: 16) {
            Text("Lista de canciones")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
            
//            ScrollView(.vertical) {
//                if musicVideoRepository.songs.count > 0 {
//                    VStack(spacing: 32) {
//                        ForEach(musicVideoRepository.songs) { song in
//                            VStack {
//                                YoutubeEmbedView(videoID: song.videoUrl, playlistID: nil)
//                                    .frame(height: 220)
//                                    .cornerRadius(12)
//                                    .shadow(radius: 4)
//                            }
//                        }
//                    }
//                }
//            }
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
