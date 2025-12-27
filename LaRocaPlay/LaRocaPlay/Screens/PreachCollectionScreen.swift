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
    case loaded([PreachDTO])
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
    
    init(collectionId: Int, collectionItems: [CollectionItem]) {
        self._collectionId = State(initialValue: collectionId)
        self.collectionItems = collectionItems
    }
    
    var collectionItems: [CollectionItem]
    
    var preaches: [PreachDTO] {
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
//            VStack {
//                ForEach(collectionItems.sorted(by: { $0.position <= $1.position })) { item in
//                    HStack {
//                        if let preach = item.preach {
//                            if item.position != 0 {
//                                Text(item.position, format: .number)
//                            }
//                            Text(preach.title)
//                        }
//                    }
//                }
//            }
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
                    VStack {
                        VStack {
                            ItemsList(items: collectionItems.sorted(by: { $0.position <= $1.position }), listView: listView) // For debug
                        }
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
