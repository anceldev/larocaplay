//
//  MusicScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 12/10/25.
//

import SwiftUI
import SwiftData
import AVKit

struct MusicScreen: View {
    @Environment(LibraryManager.self) var libManager
    @State private var showVideo: Bool = false

    @State private var selectedSong: Song? = nil
    @Query(sort: \Song.title, order: .forward) private var songs: [Song]

    var body: some View {
        VStack {
            TopBarScreen(title: "Karaoke")
            VStack {
                Text("***Canta y Adora***")
                    .font(.system(size: 16))
                Text("Encuentra las pistas con letra de tus canciones favoritas y convierte cualquier lugar en un espacio de alabanza.")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 14))
                    .padding(.horizontal, 24)
            }
            .padding(.bottom, 4)
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.customGray.opacity(0.2))
                        .frame(height: 1)
                    ForEach(songs) { song in
                        SongRow(song: song)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(item: $selectedSong, content: { song in
            YoutubeContainerView(videoId: song.videoId)
        })
        .padding(.horizontal, 18)
        .padding(.bottom, 16)
        .background(.customBlack)
        .enableInjection()
        .onAppear {
            Task {
                await libManager.loadSongs()
            }
        }
    }
    @ViewBuilder
    func SongRow(song: Song) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            
            Button {
                selectedSong = song
            } label: {
                HStack {
                    Text(song.title)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(.white)
                    Spacer()
                    if selectedSong == song {
                        Image(systemName: "play.fill")
                            .tint(.customRed)
                    } else {
                        Image(.film)
                            .foregroundStyle(.customGray)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            Rectangle()
                .fill(Color.customGray.opacity(0.2))
                .frame(height: 1)
        }
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
