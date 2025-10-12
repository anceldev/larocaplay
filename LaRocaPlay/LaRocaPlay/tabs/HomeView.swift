//
//  HomeView.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 1/8/25.
//

import SwiftUI

struct HomeView: View {
    @Environment(PreachesRepository.self) var repository
    @State private var searchQuery: String = ""
    
    var preaches: [Preach] {
        if searchQuery.isEmpty {
            return repository.preaches
        }
        return repository.preaches.filter { $0.title.lowercased().contains(searchQuery.lowercased()) }
    }
    var body: some View {
        VStack {
            ScrollView(.vertical) {
                // TODO: Añadir última predica subida y resument del fin de semana, si lo hubiese
                VStack {
                    Image(.thumbPreview)
                        .resizable()
                        .aspectRatio(16/9, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                VStack(spacing: 16) {
                    
                    
                    // TODO: últimas 4 predicas añadidas.
                    VStack {
                        Text("Últimas predicaciones")
//                            .foregroundStyle(.customBlack)
                            .foregroundStyle(.dirtyWhite)
                            .font(.system(size: 18, weight: .medium))
                        TextField("Buscar...", text: $searchQuery)
                            .textFieldStyle(.customTextFieldStyle)
                            .padding(.bottom, 14)
                        
                        ItemsList(preaches: preaches) // For debug
                    }
                    SeriesCard()
                    
                    // TODO: Boton que lleva al directo de la celebración
                    StreamingCard()
                    // TODO: Enlace a congresos que se han realizado (Aquí se puede añadir varios videos a un congreso específico, como el fin de semana de la visión por ejemplo).
                    EventsCard()
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
