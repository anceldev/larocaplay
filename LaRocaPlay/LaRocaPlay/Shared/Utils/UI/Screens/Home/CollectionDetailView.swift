//
//  CollectionDetailView.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 14/1/26.
//

import SwiftUI
import SwiftData

enum ItemsListOrder {
    case position
    case date
}

struct CollectionDetailView: View {
    @Environment(LibraryManager.self) var libManager
    
    let collection: Collection
    var listOrder: ItemsListOrder
    var backButton: Bool
    
    init(collection: Collection, order: ItemsListOrder, backButton: Bool = true) {
        self.collection = collection
        self.listOrder = order
        self.backButton = backButton
    }
    
    
    var body: some View {
        VStack(spacing: 0) {
            TopBarScreen(title: collection.title, backButton)
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
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.appLabel.primary)
                        if let description = collection.desc {
                            ExpandableDescription(descriptionText: description)
                        }
                    }
                    
                }
                if !collection.items.isEmpty {
                    
                    CollectionItemsView(items: listOrder == .date ? collection.itemsSortedByDate : collection.itemsSortedByPosition)
                } else {
                    EmptyContent {
                        Text("Todavía no hay contenido para esta colección.")
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                            .foregroundStyle(.appLabel.secondary)
                    }
                }
            }
        }
        .background(.appBackground.primary)
        .enableInjection()
    }
    
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}
