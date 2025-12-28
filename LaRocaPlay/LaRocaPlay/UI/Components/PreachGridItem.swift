//
//  PreachGridItem.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 13/9/25.
//

import SwiftUI



struct PreachGridItem: View {
    let item: CollectionItem
    let listView: ListView
    let aspect: CGFloat
    
//    init(_ preach: Preach, listView: ListView = .single, aspect: CGFloat = 16/9, titleAlignment: TextAlignment = .leading, item: CollectionItem) {
//        self.preach = preach
    init(item: CollectionItem, listView: ListView = .single, aspect: CGFloat = 16/9, titleAlignment: TextAlignment = .leading) {

        self.listView = listView
        self.aspect = aspect
        self.item = item
    }
    var body: some View {
        VStack {
            if let teach = item.preach {
                switch listView {
                case .single, .grid:
                    TeachingCard(teach: teach, listView: listView)
                case .list:
                    TeachingRow(teach: teach, position: item.position)
                }
            }
        }
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}
