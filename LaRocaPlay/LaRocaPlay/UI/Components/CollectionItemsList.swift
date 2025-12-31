//
//  CollectionItemsList.swift
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
    
    var titleSize: CGFloat {
        switch self {
        case .single:   20
        case .grid:     14
        case .list:     14
        }
    }
    var subtitleSize: CGFloat {
        switch self {
        case .single:   16
        case .grid:     12
        case .list:     12
        }
    }
    var textAlignment: Alignment {
        switch self {
        case .single:   .center
        case .grid:     .leading
        case .list:     .leading
        }
    }
    var tAlignment: TextAlignment {
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
    var colSpacing: CGFloat {
        switch self {
        case .single:   20
        case .grid:     14
        case .list:     8
        }
    }
}

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
