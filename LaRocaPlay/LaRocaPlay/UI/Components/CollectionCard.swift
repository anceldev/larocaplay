//
//  EventsCard.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 15/9/25.
//

import SwiftUI

struct CollectionCard: View {
    @Environment(AppRouter.self) var router
    
//    var collection: PreachCollection
    var collection: Collection
    
    var body: some View {
        VStack {
            Button {
                router.navigateTo(.collection(id: collection.id))
            } label: {
                ThumbImageLoader(title: collection.title, storageCollection: .collections(collection.imageId))
                    .blur(radius: 1)
                    .overlay(alignment: .center) {
                        Text(collection.title)
                            .foregroundStyle(.white)
                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                            .shadow(color: .black.opacity(0.8), radius: 5, x: 0, y: 0)
                    }
            }
        }
//        .padding(6)
        .background(.blue.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.player))
        .enableInjection()
    }
    
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}
