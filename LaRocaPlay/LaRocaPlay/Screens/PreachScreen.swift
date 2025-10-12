//
//  PreachScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 2/8/25.
//

import SwiftUI

enum FetchState {
    case loading
    case completed
    case notFound
    case error
}

struct PreachScreen: View {
    @Environment(AppRouter.self) var router
    @Environment(PreachesRepository.self) var preaches
//    var id: Int
    var preach: Preach
    @State private var fetchState: FetchState = .completed
//    @State private var preach: Preach?
    
    var body: some View {
        VStack {
            Group {
                switch fetchState {
                case .loading:
                    ProgressView()
                case .completed:
                    PreachView(preach: preach)
                case .notFound:
                    Text("No se pudo encontrar la predica")
                case .error:
                    Text("Ha habido un error al intentar obtener la predica seleccionado, por favor vuelve a intentarlo")
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    router.popNavigation()
                } label: {
                    HStack {
//                        Label("La Roca Play", systemImage: "chevron.left")
                        Image(systemName: "chevron.left")
                        Text("Atrás")
                            .foregroundStyle(.customRed)
                    }
                }
            }
        })
        .onAppear {
            fetchPreach()
        }
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
    private func fetchPreach() {
//        self.preach = preaches.preaches.first(where: { $0.id == self.id })
//        guard self.preach != nil else {
//            fetchState = .notFound
//            return
//        }
//        fetchState = .completed
    }
}
