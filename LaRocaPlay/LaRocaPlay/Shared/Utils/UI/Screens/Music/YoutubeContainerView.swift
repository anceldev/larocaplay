//
//  YoutubeContainerView.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 9/1/26.
//

import SwiftUI

struct YoutubeContainerView: View {
    let videoId: String
    @State private var isLoading = true
    var body: some View {
        VStack {
            YouTubePlayerView(videoID: videoId)
            .aspectRatio(16/9, contentMode: .fit)
            .mask(RoundedRectangle(cornerRadius: 30))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(18)
    }
}
