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
            }
        }
        .padding(6)
        .background(.dirtyWhite)
        .clipShape(RoundedRectangle(cornerRadius: 26))
        .enableInjection()
    }
    
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}
