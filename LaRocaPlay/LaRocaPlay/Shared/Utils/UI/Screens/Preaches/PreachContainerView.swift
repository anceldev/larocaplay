//
//  PreachContainerView.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 14/1/26.
//

import SwiftUI



struct PreachContainerView: View {
    @Environment(LibraryManager.self) var libManager
    @State private var state: ViewState = .loading
    
    let itemId: Int
    let isDeepLink: Bool
    
    var body: some View {
        VStack {
            Group {
                switch state {
                case .loading:
                    ProgressView()
                case .succes(let preach):
                    PreachDetailView(preach: preach)
                case .error(let errorMessage):
                    Text(errorMessage)
                }
            }
            .task {
                await loadPreach()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.customBlack)
        .enableInjection()
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
    private func loadPreach() async {
        do {
            let preach = try await libManager.getCollectionItem(id: itemId, isDeepLink: isDeepLink)
            state = .succes(preach)
        } catch let error as LibManagerError {
            switch error {
            case .noCollectionItemFound(let message):
                state = .error(message)
            }
            return
        } catch {
            state = .error("No se pudo cargar la prediación")
        }
    }
}

extension PreachContainerView {
    enum ViewState {
        case loading
        case succes(Preach)
        case error(String)
    }
}
