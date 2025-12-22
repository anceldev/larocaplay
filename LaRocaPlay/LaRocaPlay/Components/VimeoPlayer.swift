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

struct VimeoVideoPlayer: View {
    //    let videoId: String
    //    @State private var videoURL: URL?
    var videoURL: URL
    var thumbId: String?
    //    @State private var playerMessage: String? = nil
    var player: AVPlayer
    
    init(videoURL: URL, thumbId: String?) {
        self.videoURL = videoURL
        self.thumbId = thumbId
        self.player = AVPlayer(url: self.videoURL)
    }
    
    @State private var showPlayButton: Bool = true
    
    var body: some View {
        ZStack {
            Color.gray
            VideoPlayer(player: player)
                .aspectRatio(16/9, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            ZStack {
                ThumbImageLoader(storageCollection: .preaches(thumbId))
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
                    player.play()
                }
            }
                
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .enableInjection()
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}
