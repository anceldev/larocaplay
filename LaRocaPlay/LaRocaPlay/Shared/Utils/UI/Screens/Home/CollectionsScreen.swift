//
//  CollectionsScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 12/10/25.
//

import SwiftUI
import SwiftData

fileprivate enum CollectionFilter: String, CaseIterable, Identifiable {
    case all = "Todas"
    case allPublics = "Publicas"
    case allPrivates = "Privadas"
    
    var id: Self { self }
}


struct CollectionsScreen: View {
    @Environment(AppRouter.self) var router
    
    @State private var filterView: CollectionFilter = .all
    
    @State private var errorMessage: String? = nil
    @Query private var collections: [Collection]
    let title: String
    
    var filteredCollections: [Collection] {
        switch filterView {
        case .all: return collections
        case .allPublics: return collections.filter { $0.isPublic }
        case .allPrivates: return collections.filter { !$0.isPublic }
        }
    }
    
    
    init(typeName: String = "Serie", title: String = "Series") {
        let predicate = #Predicate<Collection> { collection in
            collection.typeName == typeName
        }
        self.title = title
        self._collections = Query(filter: predicate, sort: \Collection.title, order: .forward)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .center) {
                TopBarScreen(title: title, true)
                HStack {
                    Menu {
                        ForEach(CollectionFilter.allCases) { filter in
                            Button {
                                filterView = filter
                            } label: {
                                Text(filter.rawValue)
                            }
                        }
                    } label: {
                        Text(filterView.rawValue)
                            .font(.system(size: 12))
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .bottomTrailing)

            }
            if !filteredCollections.isEmpty {
                ScrollView(.vertical) {
                    VStack(spacing: 24) {
                        ForEach(filteredCollections) { serie in
                            Button {
                                router.navigateTo(.collection(id: serie.id))
                            } label: {
                                CollectionCard(collection: serie)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: Theme.Radius.player)
                                            .stroke(lineWidth: 8)
                                            .foregroundStyle(.gray.opacity(0.3))
                                    }
                                    .padding(.horizontal, 18)
                            }
                        }
                    }
                }
                
                .scrollIndicators(.hidden)
                
            } else {
                EmptyContent {
                    Text("No hay ninguna serie disponible.")
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }
            }
            Spacer()
        }
        .animation(.smooth, value: filterView)
        .background(.appBackground.primary)
        .enableInjection()
    }
    
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}
