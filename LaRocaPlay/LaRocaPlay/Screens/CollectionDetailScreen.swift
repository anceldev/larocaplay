//
//  CollectionDetailScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 2/12/25.
//

import SwiftUI
import SwiftData

struct CollectionDetailScreen: View {
    
    @Environment(LibraryManager.self) var libManager
    var collectionId: Int
    
    @Query private var collections: [Collection]
    
    init(collectionId: Int) {
        self.collectionId = collectionId
        let predicate = #Predicate<Collection>{ $0.id == collectionId }
        self._collections = Query(filter: predicate)
    }
    private var collection: Collection? {
        collections.first
    }
    
    var body: some View {
        VStack(spacing: 10) {
            ScrollView(.vertical) {
                
                
                VStack(spacing: 14) {
                    HeaderView(storageCollection: .collections(collection?.imageId))
                    VStack(spacing: 8) {
                        Text(collection?.title ?? "")
                            .font(.system(size: 24, weight: .bold, design: .default))
                        Text(collection?.desc ?? "")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.dirtyWhite)
                            .padding(.horizontal, 24)
                            .multilineTextAlignment(.center)
                    }
                }
                PreachCollectionScreen(collectionId: collectionId, collectionItems: collection?.items ?? [])
            }
            .scrollIndicators(.hidden)
        }
        .padding(.horizontal, 18)
        .background(.customBlack)
        .enableInjection()
        .task {
            await libManager.syncSpecificCollection(id: collectionId)
        }
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}
