//
//  TeachingRow.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 27/12/25.
//

import SwiftUI

struct TeachingRow: View {
    var teach: Preach
    var position: Int
    var body: some View {
        VStack {
            HStack(spacing: 8) {
                ZStack(alignment: .topLeading) {
                    ThumbImageLoader(storageCollection: .preaches(teach.imageId))
                    if position != 0 {
                        VStack {
                            Text(position, format: .number)
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundStyle(.dirtyWhite)
                                .padding(8)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(teach.title)
                        .foregroundStyle(.white)
                        .font(.system(size: 14, weight: .medium, design: .default))
                        .multilineTextAlignment(.leading)
                    HStack(alignment: .center , spacing: 8) {
                        HStack(spacing: 4) {
                            Text(teach.preacher?.role ?? "")
                            Text(teach.preacher?.name ?? "")
                        }
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.dirtyWhite)
                        Text(teach.date, style: .date)
                            .font(.system(size: 10))
                            .foregroundStyle(.dirtyWhite)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 8)
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: 80, alignment: .leading)
            .padding(.vertical, 6)
        }
        .enableInjection()
        
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}

