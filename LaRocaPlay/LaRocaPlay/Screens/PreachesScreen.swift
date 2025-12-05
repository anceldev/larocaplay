//
//  PreachesScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 2/12/25.
//

import SwiftUI

struct PreachesScreen: View {
    @Environment(CelebrationRepository.self) var celebration
    @State private var searchQuery = ""
    
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
            VStack(spacing: 8) {
                Text("Últimas predicaciones")
                    .foregroundStyle(.dirtyWhite)
                    .font(.system(size: 14, weight: .medium))
                
                HStack(spacing: 16) {
                    TextField("Buscar...", text: $searchQuery)
                        .textFieldStyle(.customTextFieldStyle)
                    VStack {
                        Button {
                            withAnimation(.easeIn) {
                                self.cols = cols == 1 ? 2 : 1
                            }
                        } label: {
                            Image(.gridCirclePlus)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28)
                                .foregroundStyle(self.cols == 1 ? .dirtyWhite : .customRed)
                        }
                        .padding(8)
                        .clipShape(.circle)
                        .overlay {
                            Circle().stroke(self.cols == 1 ? .dirtyWhite : .customRed, lineWidth: 1)
                        }
                    }
                    .padding(.trailing, 8)
                    
                }
                .frame(maxHeight: 56, alignment: .center)
            }
            VStack(spacing: 0) {
                    VStack {
                        ScrollView(.vertical) {
                            VStack {
                                ItemsList(preaches: preaches, cols: cols) // For debug
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
