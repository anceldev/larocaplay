//
//  TeachingCard.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 27/12/25.
//

import SwiftUI

struct TeachingCard: View {
    var teach: Preach
    var listView: ListView
    var body: some View {
        VStack(spacing: 8) {
            ThumbImageLoader(storageCollection: .preaches(teach.imageId))
            VStack(alignment: .center, spacing: 4) {
                Text(teach.title)
                    .foregroundStyle(.white)
                    .font(.system(size: 16, weight: .medium, design: .default))
                    .multilineTextAlignment(.center)
                HStack(alignment: .center , spacing: 4) {
                    HStack(alignment: .top, spacing: 4) {
                        Text(teach.preacher?.role ?? "")
                        Text(teach.preacher?.name ?? "")
                    }
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.dirtyWhite)
                    Text("- \(teach.date, style: .date)")
                        .font(.system(size: 10))
                        .foregroundStyle(.dirtyWhite)
                }
                .frame(maxWidth: .infinity, alignment: listView.textAlignment)
            }
            .padding(.horizontal, 8)
        }
        
    }
}
