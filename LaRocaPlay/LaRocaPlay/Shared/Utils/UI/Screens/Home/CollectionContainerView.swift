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
    
    init(collectionId: Int, isDeepLink: Bool, backButton: Bool = true) {
        self.collectionId = collectionId
        self.isDeepLink = isDeepLink
    }
    
    var body: some View {
        VStack {
            ScrollView(.vertical) {
                
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
                
                .scrollIndicators(.hidden)
            }
            .refreshable {
                await refreshCollection()
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.customBlack)
            .task {
                await prepareCollection(for: collectionId)
            }
        }
        .enableInjection()
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}

extension CollectionContainerView {
    private func prepareCollection(for collectionId: Int) async {
        do {
            if collectionId == Constants.mainCollectionId {
                // TODO: Aqui hay que hacer métodos específicos con paginación para que los utilice la colección principal
                print("Función diferente si se trata de main collection, aqui tiene que haber pagination")
            } else {
                let collection = try await libManager.getCollection(id: collectionId, isDeepLink: isDeepLink)
                state = .succes(collection)
            }
        } catch {
            print(error)
            state = .error("Error al cargar la serie: \(error)")
        }
    }
    private func refreshCollection() async {
        do {
            let collection = try await libManager.refreshCollection(id: collectionId)
            state = .succes(collection)
            
        } catch {
            guard !Task.isCancelled else { return }
            print(error)
            state = .error("No se pudo actualizar la colección: \(error)")
        }
    }
    enum CollectionViewState {
        case loading
        case succes(Collection)
        case error(String)
    }
}
