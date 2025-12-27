//
//  CollectionDetailScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 2/12/25.
//

import SwiftUI
import SwiftData

struct CollectionDetailScreen: View {
    @Environment(CollectionRepository.self) var collections
    @Environment(LibraryManager.self) var libManager
    var collectionId: Int
    
    var collection: PreachCollection? {
        guard let collection = collections.series.first (where: { $0.id == collectionId }) else {
            return nil
        }
        return collection
    }
    
    @Query private var sdCollections: [Collection]
    
    init(collectionId: Int) {
        self.collectionId = collectionId
        let predicate = #Predicate<Collection>{ $0.id == collectionId }
        self._sdCollections = Query(filter: predicate)
    }
    private var collectionIs: Collection? {
        sdCollections.first
    }
    
//    @Query private var collection: Collection
    
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
            PreachCollectionScreen(collectionId: collectionId, collectionItems: collectionIs?.items ?? [])
                .padding(.horizontal)
        }
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
