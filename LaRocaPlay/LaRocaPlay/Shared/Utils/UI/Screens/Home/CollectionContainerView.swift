//
//  CollectionContainerView.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 14/1/26.
//

import SwiftUI

struct CollectionContainerView: View {
    @Environment(LibraryManager.self) var libManager
    @State private var state: Self.CollectionViewState = .loading
    
    let collectionId: Int
    let isDeepLink: Bool
//    let backButton: Bool
    
    init(collectionId: Int, isDeepLink: Bool, backButton: Bool = true) {
        self.collectionId = collectionId
        self.isDeepLink = isDeepLink
//        self.backButton = backButton
    }
    
    var body: some View {
        VStack {
            Group {
                switch state {
                case .loading:
                    ProgressView()
                case .succes(let collection):
                    CollectionDetailView(
                        collection: collection,
                        order: collectionId == 1 ? .date : .position
                    )
                case .error(let message):
                    Text(message)
                }
            }
            .task {
                await loadCollection()
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.customBlack)
        .enableInjection()
        .onAppear {
            print(collectionId)
        }
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}

extension CollectionContainerView {
    private func loadCollection() async {
        do {
            let collection = try await libManager.getCollection(id: collectionId, isDeepLink: isDeepLink)
            state = .succes(collection)
        } catch {
            print(error)
            state = .error("No se pudo cargar la serie")
        }
    }
    enum CollectionViewState {
        case loading
        case succes(Collection)
        case error(String)
    }
}
