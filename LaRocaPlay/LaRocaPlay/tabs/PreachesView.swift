//
//  PreachesView.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 1/8/25.
//

import SwiftUI
import AVKit
import AppRouter

struct PreachesView: View {
    @Environment(PreachesRepository.self) var repository
    @Environment(AppRouter.self) var router
    
    @State private var preaches: [Preach]
    
    @State private var errorMessage: String?
    @State private var searchQuery = ""
    
    init(preaches: [Preach]) {
        self._preaches = .init(initialValue: preaches)
    }
    var filteredPreaches: [Preach] {
        if searchQuery.isEmpty {
            return repository.preaches
        }
        return repository.preaches.filter { $0.title.lowercased().contains(searchQuery.lowercased()) }
    }
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Lista de predicas")
                .font(.system(size: 24, weight: .medium))
//                .foregroundStyle(.customBlack)
            TextField("Buscar...", text: $searchQuery)
                .textFieldStyle(.customTextFieldStyle)
                .foregroundStyle(searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .white : .dirtyWhite)
                .padding(.bottom, 14)
            VStack(alignment: .center) {
                Spacer()
                if preaches.isEmpty {
                    Text("No hay contenido de prédicas para mostrar.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.customBlack)
                        .opacity(0.5)
                }
                else {
                    ScrollView(.vertical) {
//                        ItemsList(preaches: repository.preaches)
                        ItemsList(preaches: filteredPreaches)
                    }
                    .scrollIndicators(.hidden)
                }
                Spacer()
            }
//            .padding(.horizontal, 24)
            if !repository.isFull && !repository.preaches.isEmpty {
                Button {
                    fetchPreaches()
                } label: {
                    Text("Cargar más")
                }
            }
        }
        .padding()
        .background(.customBlack)
        .enableInjection()
    }
    
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
    private func fetchPreaches() {
        Task {
            do {
                let newPreaches = try await repository.getPreaches()
                self.preaches.append(contentsOf: newPreaches)
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
