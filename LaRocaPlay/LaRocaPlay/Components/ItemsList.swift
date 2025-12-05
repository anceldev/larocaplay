//
//  ItemsList.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 13/9/25.
//

import SwiftUI
import AppRouter

struct ItemsList: View {
    
    @Environment(AppRouter.self) var router
    let preaches: [Preach]
    let cols: Int
    
    init(preaches: [Preach], cols: Int = 2) {
        self.preaches = preaches
        self.cols = cols
    }
    
    var columns: [GridItem] {
        Array(repeating: GridItem(.flexible()), count: cols)
    }
    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(preaches) { item in
                Button {
                    router.navigateTo(.preach(preach: item))
                } label: {
                    PreachGridItem(item, aspect: cols == 2 ? 4/3 : 16/9)
                }
            }
        }
        .enableInjection()
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}
