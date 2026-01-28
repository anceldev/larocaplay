//
//  CollectionItemsList.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 13/9/25.
//

import SwiftUI
import AppRouter

struct CollectionItemsList: View {
    
    @Environment(AppRouter.self) var router

    let cols: Int
    
    var items: [CollectionItem]
    var listView: ListView
    init(items: [CollectionItem], listView: ListView) {
        self.items = items
        self.listView = listView
        self.cols = self.listView == .grid ? 2 : 1
    }
    
    var columns: [GridItem] {
        Array(repeating: GridItem(.flexible()), count: cols)
    }
    var body: some View {
        VStack {
            LazyVGrid(columns: columns, spacing: listView.colSpacing) {
                ForEach(items) { item in
                    if item.preach != nil, item.collection != nil {
                        Button {
                            router.navigateTo(.preachDetail(id: item.id))
                        } label: {
                            PreachGridItem(item: item, listView: listView)
                        }
                        .frame(maxHeight: .infinity, alignment: .top)
                    }
                }
            }
        }
        .enableInjection()
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}
