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
}

struct ItemsList: View {
    
    @Environment(AppRouter.self) var router
    let preaches: [PreachDTO]
    let cols: Int
    
    var listView: ListView
    
    init(preaches: [PreachDTO], cols: Int = 2, listView: ListView) {
        self.preaches = preaches
//        self.cols = cols
        self.listView = listView
        self.cols = self.listView == .grid ? 2 : 1
        
    }
    
    var columns: [GridItem] {
        Array(repeating: GridItem(.flexible()), count: cols)
    }
    var body: some View {
        VStack {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(preaches) { item in
                    Button {
                        router.navigateTo(.preach(preach: item))
                    } label: {
                        PreachGridItem(item, listView: listView)
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                }
            }
        }
        .enableInjection()
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}
