//
//  CollectionItemsView.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 26/11/25.
//

import SwiftUI


struct CollectionItemsView: View {
    @State private var searchQuery = ""
    @State private var cols: Int = 1
    @State private var listView: ListView = .grid
    @State private var image: UIImage?

    var items: [CollectionItem]

    var filteredItems: [CollectionItem] {
        if searchQuery.isEmpty {
            return self.items
        } else {
            return self.items.filter { $0.preach?.title.lowercased().contains(searchQuery.lowercased()) ?? false }
        }
    }
    
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Text("Últimas predicaciones")
                    .foregroundStyle(.dirtyWhite)
                    .font(.system(size: 14, weight: .medium))
                
                HStack(spacing: 16) {
                    TextField("Buscar...", text: $searchQuery)
                        .textFieldStyle(.customTextFieldStyle(46))
                    ListViewButton(listView: $listView)
                }
                .frame(maxHeight: 56, alignment: .center)
            }
            
            VStack(spacing: 0) {
                CollectionItemsList(
                    items: items,
                    listView: listView
                )
            }
        }
        .background(.customBlack)
        .enableInjection()
    }
    
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}
