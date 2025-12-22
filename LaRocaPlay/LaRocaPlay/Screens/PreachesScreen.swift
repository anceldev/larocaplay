//
//  PreachesScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 2/12/25.
//

import SwiftUI

struct PreachesScreen: View {
    @Environment(CelebrationRepository.self) var celebration
    @Environment(AppRouter.self) var router
    @State private var searchQuery = ""
    @State private var listView: ListView = .list
    
    let collectionId: Int
    @State private var cols: Int = 1
    @State private var errorMessage: String? = nil
    
    var preaches: [Preach] {
        if searchQuery.isEmpty {
            return celebration.preaches
        }
        return celebration.preaches.filter { $0.title.lowercased().contains(searchQuery.lowercased()) }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            TopBarScreen(title: "Predicaciones")
            VStack {
                VStack {
                    Text("Última celebración")
                        .font(.system(size: 14, weight: .semibold))
                    Button {
                        withAnimation(.easeIn) {
                            router.navigateTo(.preach(preach: preaches[0]))
                        }
                    } label: {
                        PreachGridItem(preaches[0], aspect: 16/9)
                            .frame(maxWidth: .infinity)
                    }
                    .border(.yellow, width: 1)
                    .border(.pink, width: 1)
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                .border(.green, width: 1)
                VStack(spacing: 8) {
                    Text("Últimas predicaciones")
                        .foregroundStyle(.dirtyWhite)
                        .font(.system(size: 14, weight: .medium))
                    
                    HStack(spacing: 16) {
                        TextField("Buscar...", text: $searchQuery)
                            .textFieldStyle(.customTextFieldStyle)
                        ListViewButton(listView: $listView)
                    }
                    .frame(maxHeight: 56, alignment: .center)
                }
            }
            VStack(spacing: 0) {
                VStack {
                    ScrollView(.vertical) {
                        VStack {
                            ItemsList(preaches: Array(preaches.dropFirst()), cols: cols, listView: listView) // For debug
                        }
                        Button {
                            withAnimation(.easeIn) {
                                loadMore()
                            }
                        } label: {
                            Text("Cargar más")
                        }
                        .disabled(celebration.isFull)
                        .opacity(celebration.isFull ? 0 : 1).animation(.easeInOut, value: celebration.isFull)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            if let errorMessage {
                Text(errorMessage)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.orange)
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
        .background(.customBlack)
        .enableInjection()
    }
    private func loadMore() {
        Task {
            do {
                try await celebration.getCelebrationPreaches()
            } catch {
                print(error)
                self.errorMessage = "Ha ocurrido un error al intentar cargar más predicas de la celebración."
            }
        }
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
    
}
