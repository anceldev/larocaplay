//
//  CollectionsScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 12/10/25.
//

import SwiftUI
import SwiftData

struct CollectionsScreen: View {
    @Environment(AppRouter.self) var router
    
    @State private var errorMessage: String? = nil
    @Query private var series: [Collection]
    let title: String
    
    init(typeName: String = "Serie", title: String = "Series") {
        let predicate = #Predicate<Collection> { collection in
            collection.typeName == typeName
        }
        self.title = title
        self._series = Query(filter: predicate, sort: \Collection.title, order: .forward)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TopBarScreen(title: title, true)
            if series.isEmpty {
                Text("No hay datos añadidos todavía")
            } else {
                ScrollView(.vertical) {
                    VStack(spacing: 24) {
                        ForEach(series) { serie in
                            Button {
                                router.navigateTo(.collection(id: serie.id))
                            } label: {
                                CollectionCard(collection: serie)
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        .padding(.horizontal)
        .background(.customBlack)
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
    
    private func getCollections() async {
    }
}
