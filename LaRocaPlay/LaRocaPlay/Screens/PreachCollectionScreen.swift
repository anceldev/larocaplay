//
//  PreachCollectionScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 26/11/25.
//

import SwiftUI


struct PreachCollectionScreen: View {
    @State private var searchQuery = ""
    @State var collectionId: Int
    @State private var cols: Int = 1
    @State private var listView: ListView = .grid
    @State private var image: UIImage?
    var collectionItems: [CollectionItem]
    
    init(collectionId: Int, collectionItems: [CollectionItem]) {
        self._collectionId = State(initialValue: collectionId)
        self.collectionItems = collectionItems
    }
    
    
    var body: some View {
        VStack(spacing: 16) {
//            ScrollView(.vertical) {
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
                    VStack {
                        VStack {
                            ItemsList(items: collectionItems.sorted(by: { $0.position <= $1.position }), listView: listView) // For debug
                        }
                    }
                }
//            }
//            .scrollIndicators(.hidden)
        }
        .background(.customBlack)
        .enableInjection()
    }
    
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}
