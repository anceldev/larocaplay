//
//  PreachCollectionScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 26/11/25.
//

import SwiftUI


enum LoadingState: Equatable {
    case loading
    case empty
    case loaded([Preach])
    case error(String)
}

struct PreachCollectionScreen: View {
    @Environment(CollectionRepository.self) var collections
    @State private var searchQuery = ""
    
    @State var collectionId: Int
    
    @State var loadingState: LoadingState = .loading
    @State private var cols: Int = 1
    @State private var listView: ListView = .grid
    @State private var image: UIImage?
    
    init(collectionId: Int) {
        self._collectionId = State(initialValue: collectionId)
    }
    
    var preaches: [Preach] {
        guard let preaches = collections.series.first (where: { $0.id == collectionId })?.preaches else {
            return []
        }
        if searchQuery.isEmpty {
            return preaches
        }
        return preaches.filter { $0.title.lowercased().contains(searchQuery.lowercased()) }
    }
    var collection: PreachCollection? {
        guard let collection = collections.series.first (where: { $0.id == collectionId }) else {
            return nil
        }
        return collection
    }
    
    var body: some View {
        VStack(spacing: 16) {
            //            ThumbImageLoader(title: collection?.title, storageCollection: .collections(collection?.thumbId))
            ScrollView(.vertical) {
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
                
                VStack(spacing: 0) {
                    switch loadingState {
                    case .loading:
                        ProgressView()
                    case .empty:
                        Text("Todavía no hay ningún contenido en esta colección")
                    case .loaded(let array):
                        VStack {
                            //                        ScrollView(.vertical) {
                            VStack {
                                //                                ItemsList(preaches: preaches, cols: cols) // For debug
                                ItemsList(preaches: preaches, cols: cols, listView: listView) // For debug
                            }
                            //                        }
                            //                        .scrollIndicators(.hidden)
                        }
                    case .error(let message):
                        Text("Error: \(message)")
                            .foregroundStyle(.orange)
                            .font(.system(size: 12, weight: .semibold))
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .background(.customBlack)
        .onAppear {
            Task {
                await getState()
            }
        }
        
        .enableInjection()
    }
    
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
    
    private func getState() async {
        do {
            try await collections.getSeriePreaches(serieId: collectionId)
            if preaches.count == 0 {
                self.loadingState = .empty
                return
            }
            self.loadingState = .loaded(preaches)
        } catch {
            print(error)
            print(error.localizedDescription)
            self.loadingState = .error(error.localizedDescription)
        }
    }
}
