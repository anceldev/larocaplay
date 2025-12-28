//
//  ItemsList.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 13/9/25.
//

import SwiftUI
import AppRouter

enum ListView {
    case single
    case grid
    case list
    
    var fontSize: CGFloat {
        switch self {
        case .single:   20
        case .grid:     16
        case .list:     14
        }
    }
    var textAlignment: Alignment {
        switch self {
        case .single:   .center
        case .grid:     .leading
        case .list:     .leading
        }
    }
    var hAlignment: HorizontalAlignment {
        switch self {
        case .single:   .center
        case .grid:     .leading
        case .list:     .leading
        }
    }
}

struct ItemsList: View {
    
    @Environment(AppRouter.self) var router
//    let preaches: [PreachDTO]
//    let preaches: [Preach]
    let cols: Int
    
    var items: [CollectionItem]
//    var collectionItem: CollectionItem
    
    var listView: ListView
    
//    init(preaches: [PreachDTO], cols: Int = 2, listView: ListView) {
    init(items: [CollectionItem], listView: ListView) {
//        self.cols = cols
        self.items = items
        self.listView = listView
        self.cols = self.listView == .grid ? 2 : 1
    }
    
    var columns: [GridItem] {
        Array(repeating: GridItem(.flexible()), count: cols)
    }
    var body: some View {
        VStack {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(items) { item in
                    if let preach = item.preach {
                        Button {
                            router.navigateTo(.preach(preach: preach))
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
