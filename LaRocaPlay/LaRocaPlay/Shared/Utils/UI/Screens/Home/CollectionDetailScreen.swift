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
            if let collection {
                ScrollView(.vertical) {
                    VStack(spacing: 12) {
                        VStack(spacing: 14) {
                            if let imageId = collection.imageId {
                                if #available(iOS 26.0, *) {
                                    HeaderView(storageCollection: .collections(imageId))
                                        .glassEffect(in: RoundedRectangle(cornerRadius: Theme.Radius.player))
                                } else {
                                    HeaderView(storageCollection: .collections(imageId))
                                }
                            } else {
                                Color.gray
                                    .aspectRatio(16/9, contentMode: .fit)
                                    .mask(RoundedRectangle(cornerRadius: Theme.Radius.player))
                            }
                            VStack(spacing: 8) {
                                Text(collection.title)
                                    .font(.system(size: 24, weight: .bold, design: .default))
                                if let description = collection.desc {
                                    ExpandableDescription(descriptionText: description)
                                }
                            }
                            
                        }
                        if !collection.items.isEmpty {
                            CollectionItemsView(
//                                collectionId: collectionId,
                                collectionItems: collection.items,
                                order: listOrder
                            )
                        } else {
                            EmptyContent {
                                Text("Todavía no hay para esta colección.")
                                    .font(.system(size: 18, weight: .regular, design: .rounded))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 16)
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
            } else {
                EmptyContent {
                    Text("No hay datos sobre esta colección.")
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }
            }
        }
        .padding(.horizontal, 18)
        .background(.customBlack)
        .enableInjection()
        .task {
            await loadCollectionItems()
        }
    }
    private func loadCollectionItems() async {
        guard let collection else { return }
        do {
            try await libManager.syncCollectionItems(for: collection)
        } catch {
            print(error)
            print(error.localizedDescription)
        }
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}
