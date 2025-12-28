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
    
    
    var body: some View {
        VStack(spacing: 16) {
            TopBar()
//                .border(.pink, width: 1)
            VStack {
                ScrollView(.vertical) {
                    VStack(spacing: 24) {
                        if let streamingUrl {
                            StreamingCard(streamingUrl: streamingUrl)
                        }
                        VStack(spacing: 24) {
                            if let mainCollection, !mainCollection.items.isEmpty {
                                VStack {
                                    VStack {
                                        Text("Última celebración")
                                            .font(.system(size: 14, weight: .semibold))
                                        Text("Descubre las últimas predicaciones")
                                            .font(.system(size: 12, weight: .medium, design: .rounded))
                                            .foregroundStyle(.dirtyWhite)
                                    }
                                    Button {
                                        router.navigateTo(.preach(preach: mainCollection.items[0].preach!))
                                    } label: {
                                        PreachGridItem(item: mainCollection.items[0], aspect: 16/9, titleAlignment: .center)
                                    }
                                }
                            }
                            HStack {
                                Button {
                                    withAnimation(.easeIn) {
                                        router.selectedTab = .preaches
                                    }
                                } label: {
                                    Text("Ver más predicaciones")
                                        .foregroundStyle(.customBlack)
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                }
                            }
                            .padding(8)
                            .frame(maxWidth: .infinity)
                            .background(.dirtyWhite)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        if homeCollections.count > 0 {
                            VStack {
                                ForEach(homeCollections) { homeCollection in
                                    Button {
                                        router.navigateTo(.collection(id: homeCollection.id))
                                    } label: {
                                        ThumbImageLoader(title: homeCollection.title,storageCollection: .collections(homeCollection.imageId))
                                    }
                                }
                            }
                        }
                        
                        VStack(spacing: 24) {
                            SeriesCard()
                            // TODO: Enlace a congresos que se han realizado (Aquí se puede añadir varios videos a un congreso específico, como el fin de semana de la visión por ejemplo).
                            EventsCard()
                        }
                        .background(.customBlack.opacity(0.5))
                        
                    }
                    
                }
                .scrollIndicators(.hidden)
            }
        }
        .padding()
        .background(.customBlack)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .enableInjection()
    }
    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}
