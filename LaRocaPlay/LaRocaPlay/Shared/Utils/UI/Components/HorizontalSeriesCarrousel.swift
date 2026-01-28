//
//  HorizontalSeriesCarrousel.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 28/1/26.
//

import SwiftUI

struct HorizontalSeriesCarrouselView: View {
    @Environment(AppRouter.self) private var router
    var items: [Collection]
    //    @State var visibleItem: CardItem? = cardItems.first
    //    @State private var visibleItem: CollectionItem? = items.first
//    @State private var visibleItem: CollectionItem?
    @State private var visibleItem: Int?
    
    init(items: [Collection]) {
        self.items = items
        self._visibleItem = State(initialValue: items.first?.id)
    }
    
    var body: some View {
        VStack {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(items) { item in
                            Button {
                                router.navigateTo(.collection(id: item.id, isDeepLink: false))
                            } label: {
                                ThumbImageLoader(
                                    title: item.title,
                                    storageCollection: .collections(item.imageId)
                                )
                            }
                        }
                    }
                }
                .scrollTargetLayout()
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $visibleItem)
            }
            .aspectRatio(16/9, contentMode: .fit)
            .background(.gray.opacity(0.3))
            .clipShape(.rect(cornerRadius: Theme.Radius.player))
            .overlay {
                RoundedRectangle(cornerRadius: Theme.Radius.player)
                    .stroke(lineWidth: 8)
                    .foregroundStyle(.gray.opacity(0.3))
            }
            .padding(.horizontal, 18)
            .overlay(alignment: .bottom) {
                HStack {
                    HStack(spacing: 12) {
                        ForEach(items) { item in
                            Circle()
                                .frame(width: item.id == visibleItem ? 8 : 6, height: item.id == visibleItem ? 8 : 6)
                                .foregroundStyle(item.id == visibleItem ? .white : .gray)
                                .animation(.linear, value: visibleItem)
                        }
                        .padding(.bottom, 8)
                    }
                }
            }
        }
        .enableInjection()
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}
