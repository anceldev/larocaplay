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
                case .succes(let item):
//                    PreachDetailView(item: preach)
                    PreachDetailView(item: item)
                case .error(let errorMessage):
                    Text(errorMessage)
                }
            }
            .task {
                await loadPreach()
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.customBlack)
        .enableInjection()
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
    private func loadPreach() async {
        do {
//            let preach = try await libManager.getCollectionItem(id: itemId, isDeepLink: isDeepLink)
            let item = try await libManager.getCollectionItem(id: itemId, isDeepLink: isDeepLink)
            guard let preach = item.preach, let collection = item.collection else {
                state = .error("No se encontro la enseñanza asociada a la serie")
                return
            }
//            state = .succes(preach)
            state = .succes(item)
        } catch let error as LibManagerError {
            switch error {
            case .noCollectionItemFound(let message):
                state = .error(message)
            }
            return
        } catch {
            print(error)
            state = .error("No se pudo cargar la prediación")
        }
    }
}

extension PreachContainerView {
    enum ViewState {
        case loading
//        case succes(Preach)
        case succes(CollectionItem)
        case error(String)
    }
}
