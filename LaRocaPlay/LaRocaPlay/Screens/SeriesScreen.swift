//
//  SeriesScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 12/10/25.
//

import SwiftUI
import SwiftData

struct SeriesScreen: View {
    @Environment(AppRouter.self) var router
    @Environment(CollectionRepository.self) var seriesRepository
    
    @State private var errorMessage: String? = nil
    
    @Query(filter: #Predicate<Collection>{ collection in
        collection.typeName == "Serie"
    }, sort: \Collection.title, order: .forward) private var series: [Collection]
    
    var body: some View {
        VStack(spacing: 0) {
            TopBarScreen(title: "Series", true)
            if series.isEmpty {
                Text("No hay ninguna serie añadida")
            } else {
                ScrollView(.vertical) {
                    VStack(spacing: 24) {
                        ForEach(series) { serie in
                            Button {
                                router.navigateTo(.collection(id: serie.id, cols: 2))
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
        do {
            if seriesRepository.series.isEmpty {
                try await self.seriesRepository.getCollections()
            }
        } catch {
            print(error)
            self.errorMessage = "No se han podido recuperar las colecciones"
        }
    }
}

//#Preview {
//    SeriesScreen()
//}
