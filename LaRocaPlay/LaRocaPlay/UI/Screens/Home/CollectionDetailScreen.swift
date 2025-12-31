//
//  CollectionDetailScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 2/12/25.
//

import SwiftUI
import SwiftData

enum ItemsListOrder {
    case position
    case date
}


struct CollectionDetailScreen: View {
    
    @Environment(LibraryManager.self) var libManager
    var collectionId: Int
    var backButton: Bool
    
    @Query private var collections: [Collection]
    var listOrder: ItemsListOrder
    
    init(collectionId: Int, order: ItemsListOrder, backButton: Bool = true) {
        self.collectionId = collectionId
        let predicate = #Predicate<Collection>{ $0.id == collectionId }
        self._collections = Query(filter: predicate)
        self.listOrder = order
        self.backButton = backButton
    }
    private var collection: Collection? {
        collections.first
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TopBarScreen(title: collection?.title ?? "", backButton)
//                .border(.yellow, width: 1)
            if let collection {
                ScrollView(.vertical) {
                    VStack(spacing: 14) {
                        if let imageId = collection.imageId {
//                            HeaderView(storageCollection: .collections(collection.imageId))
                            HeaderView(storageCollection: .collections(imageId))
                        } else {
                            Color.gray
                                .aspectRatio(16/9, contentMode: .fit)
                                .mask(RoundedRectangle(cornerRadius: Theme.Radius.player))
                            }
                        VStack(spacing: 8) {
                            Text(collection.title)
                                .font(.system(size: 24, weight: .bold, design: .default))
                            Text(collection.desc ?? "")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.dirtyWhite)
                                .multilineTextAlignment(.center)
                        }
                    }
                    CollectionItemsView(
                        collectionId: collectionId,
                        collectionItems: collection.items,
                        order: listOrder
                    )
                }
                .scrollIndicators(.hidden)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
