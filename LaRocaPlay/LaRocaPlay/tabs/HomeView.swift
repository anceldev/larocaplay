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
    
    var body: some View {
        VStack {
            ScrollView(.vertical) {
                VStack(spacing: 32) {
                    if let streamingUrl {
                        StreamingCard(streamingUrl: streamingUrl)
                    }
                    if preaches.count > 0 {
                        Button {
                            router.navigateTo(.preach(preach: preaches[0]))
                        } label: {
                            PreachGridItem(preaches[0], aspect: 16/9)
                        }
                    }
                    // TODO: últimas 4 predicas añadidas.
                    VStack {
                        Text("Últimas predicaciones")
                            .foregroundStyle(.dirtyWhite)
                            .font(.system(size: 18, weight: .medium))
                        TextField("Buscar...", text: $searchQuery)
                            .textFieldStyle(.customTextFieldStyle)
                            .padding(.bottom, 14)
                        
                        ItemsList(preaches: Array(preaches.dropFirst())) // For debug
                    }
                    VStack(spacing: 32) {
//                        SeriesCard()
                        Button {
                            router.navigateTo(.series)
                        } label: {
                            Text("Series")
                        }
                        // TODO: Enlace a congresos que se han realizado (Aquí se puede añadir varios videos a un congreso específico, como el fin de semana de la visión por ejemplo).
                        EventsCard()
                    }
                }
                
            }
            .scrollIndicators(.hidden)
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
