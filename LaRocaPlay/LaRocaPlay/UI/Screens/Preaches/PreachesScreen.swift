//
//  PreachesScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 2/12/25.
//

import SwiftUI
import SwiftData

struct PreachesScreen: View {
    @Environment(AppRouter.self) var router
    @Environment(\.modelContext) var context
    @State private var searchQuery = ""
    @State private var listView: ListView = .list
    
    let collectionId: Int
    @State private var cols: Int = 1
    @State private var errorMessage: String? = nil
    
    let mainCollectionId = 1
    
    @Query(filter: #Predicate<CollectionItem> { item in
        item.collection?.id == 1
    }, sort: \CollectionItem.preach?.date, order: .reverse) private var items: [CollectionItem]

    var filteredItems: [CollectionItem] {
        if searchQuery.isEmpty {
            return self.items
        } else {
            return self.items.filter {
                $0.preach?.title.lowercased().contains(searchQuery.lowercased()) ?? false
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TopBarScreen(title: "Predicaciones")
            VStack {
                VStack(spacing: 8) {
                    Text("Últimas predicaciones")
                        .foregroundStyle(.dirtyWhite)
                        .font(.system(size: 14, weight: .medium))
                    
                    HStack(spacing: 16) {
                        TextField("Buscar...", text: $searchQuery)
                            .textFieldStyle(.customTextFieldStyle(46))
                        ListViewButton(listView: $listView)
                    }
                }
                //                VStack {
                ScrollView(.vertical) {
                    LazyVStack {
                        VStack {
                            CollectionItemsList(items: Array(filteredItems.dropFirst()), listView: listView) // For debug
                        }
                        Button {
                            withAnimation(.easeIn) {
                                loadMore()
                            }
                        } label: {
                            Text("Cargar más")
                        }
                    }
                }
                .scrollIndicators(.hidden)
                
                if let errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
        .background(.customBlack)
        .enableInjection()
    }
    private func loadMore() {

    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
    
}
