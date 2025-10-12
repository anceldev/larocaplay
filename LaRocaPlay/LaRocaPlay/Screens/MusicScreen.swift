//
//  MusicScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 12/10/25.
//

import SwiftUI

struct MusicScreen: View {
    @State private var musicRepository = MusicRepository()
    @State private var isPlayed: Int? = nil
    
    var itemPlayed: MusicItem? {
        if let isPlayed {
            return musicRepository.music.first { $0.id == isPlayed }
        }
        return nil
    }
    var body: some View {
        VStack(spacing: 16) {
            Text("Lista de reproducción")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
            if let itemPlayed {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Reproduciendo:")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.dirtyWhite)
                    HStack {
                        Text(itemPlayed.name)
                            .font(.system(size: 20, weight: .semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            ScrollView(.vertical) {
                if musicRepository.music.count > 0 {
                    VStack(spacing: 32) {
                        ForEach(musicRepository.music) { song in
                            HStack {
                                VStack {
                                    Text(song.name)
                                    if let songDescription = song.description {
                                        Text(songDescription)
                                    }
                                }
                                Spacer()
                                Button {
                                    self.isPlayed = song.id
                                } label: {
                                    Image(.halfDottedCirclePlay)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 36)
//                                        .foregroundStyle(.customRed)
                                        .tint(isPlayed == song.id ? .customRed : .gray)
                                }
                            }
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .padding(20)
        .background(.customBlack)
        .enableInjection()
    }
    
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}

#Preview {
    MusicScreen()
}
