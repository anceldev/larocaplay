//
//  HomeView.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 1/8/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(AppRouter.self) var router
    @Environment(LibraryManager.self) var libManager
    @Environment(\.modelContext) var context
    
    @State private var searchQuery: String = ""
    @Query var collections: [Collection]
    
    var streamingUrl: String? {
        "https://www.youtube.com/watch?v=YprlCQ-wItg"
    }
    var homeCollections: [Collection] {
        collections.filter { $0.isHomeScreen == true }
    }
    var mainCollection: Collection? {
        collections.first { $0.id == 1 }
    }
    var carrouselCollectionItems: [CollectionItem] {
        guard let mainCollection else { return [] }
        return (mainCollection.items.count > 4)
        ? Array(mainCollection.itemsSortedByDate[0..<4])
        : mainCollection.itemsSortedByDate
    }
    
    var carrouselCollections: [Collection] {
        guard homeCollections.count > 0 else { return [] }
        return (homeCollections.count > 4)
        ? Array(homeCollections[0..<4])
        : homeCollections
    }
    
    var carrouselSeries: [Collection] {
        let series = collections.filter { $0.typeName == "Serie" }
        guard series.count > 0 else { return []}
        return series.count > 4
        ? Array(series[0..<4])
        : series
//        guard collections.count > 0 else { return [] }
        
    }
    var carrouselCongresses: [Collection] {
        let congresos = collections.filter { $0.typeName == "Congreso" && $0.isHomeScreen == true}
        guard congresos.count > 0 else { return []}
        return congresos.count > 4
        ? Array(congresos[0..<4])
        : congresos
    }
    
    
    var body: some View {
        VStack(spacing: 16) {
            TopBar()
            VStack {
                ScrollView(.vertical) {
                    VStack(spacing: 24) {
                        VStack {
                            if let streamingUrl {
                                if #available(iOS 26.0, *) {
                                    StreamingCard(streamingUrl: streamingUrl)
                                        .glassEffect(in: RoundedRectangle(cornerRadius: 20))
                                } else {
                                    StreamingCard(streamingUrl: streamingUrl)
                                }
                            }
                        }
                        .padding(.top, 10)
                        .padding(.horizontal, 18)
                        VStack(spacing: 24) {
//                            if let mainCollection, !mainCollection.items.isEmpty {
                            if carrouselCollectionItems.count > 0 {
                                VStack {
                                    VStack(spacing: 4) {
                                        Text("Últimas celebraciones")
                                            .font(.system(size: 14, weight: .semibold))
//                                        HorizontalCarrouselView(items: mainCollection.itemsSortedByDate)
                                        HorizontalCarrouselView(items: carrouselCollectionItems)
                                    }
                                    Button {
                                        withAnimation(.easeIn) {
                                            router.selectedTab = .preaches
                                        }
                                    } label: {
                                        Text("Ver más predicaciones")
                                            .foregroundStyle(.appLabel.primary)
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, 18)
                                }
                            }
                        }
                        
                        VStack(spacing: 24) {
                            if carrouselSeries.count > 0 {
                                VStack {
                                    VStack(spacing: 4) {
                                        Text("Series")
                                            .font(.system(size: 14, weight: .semibold))
                                        HorizontalSeriesCarrouselView(items: carrouselSeries)
                                    }
                                    Button {
                                        withAnimation(.easeIn) {
                                            router.navigateTo(.collections("Serie", "Series"))
                                        }
                                    } label: {
                                        Text("Ver todas las series")
                                            .foregroundStyle(.appLabel.primary)
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, 18)
                                }
                            }
                        }

                        if homeCollections.count > 0 {
                            VStack(spacing: 4) {
                                    Text("Retiros")
                                        .font(.system(size: 14, weight: .semibold))
                                VStack(spacing: 24) {
                                    ForEach(homeCollections.sorted(by: { $0.createdAt > $1.createdAt })) { homeCollection in
                                        Button {
                                            router.navigateTo(.collection(id: homeCollection.id))
                                        } label: {
                                            ThumbImageLoader(title: homeCollection.title,storageCollection: .collections(homeCollection.imageId))
                                                .overlay {
                                                    RoundedRectangle(cornerRadius: Theme.Radius.player)
                                                        .stroke(lineWidth: 8)
                                                        .foregroundStyle(.gray.opacity(0.3))
                                                }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 18)
                        }
                        VStack(spacing: 24) {
//                            SeriesCard()
                            // TODO: Enlace a congresos que se han realizado (Aquí se puede añadir varios videos a un congreso específico, como el fin de semana de la visión por ejemplo).
                            EventsCard()
                        }
                        .padding(.horizontal, 18)
                        .background(.customBlack.opacity(0.5))
                    }
                    
                }
                .scrollIndicators(.hidden)
                .refreshable {
                    await libManager.refreshInitialSync()
                }
            }
        }
        .background(.appBackground.primary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .enableInjection()
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}
