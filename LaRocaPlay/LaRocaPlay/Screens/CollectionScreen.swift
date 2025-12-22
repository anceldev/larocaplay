//
//  CollectionScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 2/12/25.
//

import SwiftUI

struct CollectionScreen: View {
    @Environment(CollectionRepository.self) var collections
    var collectionId: Int
    
    var collection: PreachCollection? {
        guard let collection = collections.series.first (where: { $0.id == collectionId }) else {
            return nil
        }
        return collection
    }
    
    var body: some View {
        VStack(spacing: 10) {
            VStack(spacing: 14) {
                HeaderView(storageCollection: .collections(collection?.thumbId))
                VStack(spacing: 8) {
                    Text(collection?.title ?? "")
                        .font(.system(size: 24, weight: .bold, design: .default))
                    Text(collection?.description ?? "")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.dirtyWhite)
                        .padding(.horizontal, 24)
                        .multilineTextAlignment(.center)
                }
            }
            PreachCollectionScreen(collectionId: collectionId)
                .padding(.horizontal)
        }
        .background(.customBlack)
        .enableInjection()
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}
