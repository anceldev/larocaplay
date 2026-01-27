//
//  EventsCard.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 15/9/25.
//

import SwiftUI

struct CollectionCard: View {
    @Environment(AppRouter.self) var router
    
    var collection: Collection
    
    var body: some View {
        VStack {
            Button {
                router.navigateTo(.collection(id: collection.id))
            } label: {
                if collection.imageId != nil{
                    ThumbImageLoader(
                        title: collection.title, storageCollection: .collections(collection.imageId))
                } else {
                    Color.gray
                        .aspectRatio(16 / 9, contentMode: .fit)
                        .overlay(alignment: .center) {
                            Text(collection.title)
                                .foregroundStyle(.white)
                                .font(.system(size: 24, weight: .semibold, design: .rounded))
                                .shadow(color: .black.opacity(0.8), radius: 5, x: 0, y: 0)
                        }
                }
            }
        }
        .background(.blue.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.player))
        .overlay(alignment: .bottomTrailing, content: {
            if !collection.isPublic {
                Image(.lock)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28)
                    .tint(.white)
                    .padding(.trailing, 10)
                    .padding(.bottom, 10)
                    .shadow(color: .black, radius: 5, x: 1, y: 1)
            }
        })
        .enableInjection()
    }
    
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}
