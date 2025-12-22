//
//  HomeView.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 1/8/25.
//

import SwiftUI

struct HomeView: View {
    @Environment(AppRouter.self) var router
    @Environment(PreachesRepository.self) var repository
    @Environment(CelebrationRepository.self) var celebration
    @Environment(CollectionRepository.self) var collections
    
    @State private var searchQuery: String = ""
    
//    var preaches: [Preach] {
//        if searchQuery.isEmpty {
//            return repository.preaches
//        }
//        return repository.preaches.filter { $0.title.lowercased().contains(searchQuery.lowercased()) }
//    }
    var preaches: [Preach] {
        if searchQuery.isEmpty {
            return celebration.preaches
        }
        return celebration.preaches.filter { $0.title.lowercased().contains(searchQuery.lowercased()) }
    }
    
    var streamingUrl: String? {
        guard let link = repository.externalLinks.first (where:{ $0.key == "youtube" }) else {
            return nil
        }
        return link.enabled ? link.link : nil
    }
    
    var homeCollections: [PreachCollection] {
        collections.series.filter({ $0.isHomeScreen == true })
    }
    
    var body: some View {
        VStack(spacing: 16) {
            TopBar()
                .border(.pink, width: 1)
            VStack {
                ScrollView(.vertical) {
                    VStack(spacing: 32) {
                        if let streamingUrl {
                            StreamingCard(streamingUrl: streamingUrl)
                        }
                        if preaches.count > 0 {
                            VStack {
                                Text("Última celebración")
                                    .font(.system(size: 14, weight: .semibold))
                                Button {
                                    router.navigateTo(.preach(preach: preaches[0]))
                                } label: {
                                    PreachGridItem(preaches[0], aspect: 16/9, titleAlignment: .center)
                                }
                            }
                        }
                        HStack {
                            Button {
                                withAnimation(.easeIn) {
                                    router.selectedTab = .preaches                                    
                                }
                            } label: {
                                
                                Text("Ver todas las predicaciones")
//                                    .foregroundStyle(.dirtyWhite)
                                    .foregroundStyle(.customBlack)
                                    .font(.system(size: 12, weight: .medium))
                            }
                        }
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(.dirtyWhite)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        if homeCollections.count > 0 {
                            VStack {
                                ForEach(homeCollections) { homeCollection in
                                    Button {
                                        router.navigateTo(.collection(id: homeCollection.id, cols: 2))
                                    } label: {
                                        ThumbImageLoader(title: homeCollection.title,storageCollection: .collections(homeCollection.thumbId))
                                        //                                    ZStack {
                                        //
                                        //                                        Text(homeCollection.title)
                                        //                                    }
                                    }
                                }
                            }
                        }
                        
                        
                        VStack(spacing: 32) {
                            Button {
                                router.navigateTo(.series)
                            } label: {
                                Text("Series")
                            }
                            // TODO: Enlace a congresos que se han realizado (Aquí se puede añadir varios videos a un congreso específico, como el fin de semana de la visión por ejemplo).
                            EventsCard()
                        }
                        .background(.customBlack.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
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

//#Preview {
//    HomeView()
//}
