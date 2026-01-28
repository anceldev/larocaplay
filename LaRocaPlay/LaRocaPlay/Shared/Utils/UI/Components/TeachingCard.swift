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
    var aspect: CGFloat
    var radius: CGFloat = Theme.Radius.player
    
    var preacherAndDate: String {
        let role = self.teach.preacher?.role
        let name = self.teach.preacher?.name
        let dateString = teach.date.formatted(date: .numeric, time: .omitted)
        let nameParts = [role, name]
            .compactMap { $0 }
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        let fullName = nameParts.joined(separator: " ")
        if fullName.isEmpty { return dateString }
        return "\(fullName) - \(dateString)"
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ThumbImageLoader(storageCollection: .preaches(teach.imageId),aspect: aspect ,radius: radius)
                .overlay(alignment: .bottom) {
                    VStack(alignment: listView.hAlignment, spacing: 0) {
                        Text(teach.title)
                            .foregroundStyle(.white)
                            .font(.system(size: listView.titleSize, weight: .medium, design: .default))
                            .multilineTextAlignment(listView.tAlignment)
                            .lineLimit(listView == .grid ? 1 : nil)
                            .frame(maxWidth: .infinity, alignment: listView.textAlignment)
                        Text(preacherAndDate)
                            .font(.system(size: listView.subtitleSize, weight: .medium, design: .rounded))
                            .foregroundStyle(.dirtyWhite)
                            .multilineTextAlignment(listView.tAlignment)
                            .lineLimit(listView == .grid ? 1 : nil)
                            .frame(maxWidth: .infinity, alignment: listView.textAlignment)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, listView.textPadding)
                    .background(
                        Rectangle()
                                .fill(.ultraThinMaterial)
                                .mask {
                                    VStack(spacing: 0) {
                                        LinearGradient(
                                            colors: [
                                                Color.black.opacity(1),
                                                Color.black.opacity(0),
                                            ],
                                            startPoint: .bottom,
                                            endPoint: .top
                                        )
                                        Rectangle()
                                    }
                                }
                            .clipShape(
                                UnevenRoundedRectangle(
                                    bottomLeadingRadius: listView == .grid ? Theme.Radius.medium : Theme.Radius.player,
                                    bottomTrailingRadius: listView == .grid ? Theme.Radius.medium : Theme.Radius.player
                                )
                            )
                    )
                    .frame(maxWidth: .infinity, alignment: listView.textAlignment)
                }
        }
        .enableInjection()
    }
#if DEBUG
  @ObserveInjection var forceRedraw
#endif
}
