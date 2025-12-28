//
//  DiscipleshipScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 15/9/25.
//

import SwiftUI
import SwiftData

// TODO: Crear una carpeta 'resources' en Storage, para que la imagen de carga aquí sea dinámica, y tener una imagen por defecto en caso de que no se pueda obtener la remota

struct DiscipleshipListScreen: View {
    @Environment(AppRouter.self) var router
    @Environment(AuthService.self) var auth
//    @Environment(CollectionRepository.self) var collectionsRepository
    
//    let role: UserRole
    @State private var errorMessage: String? = ""
    
    @Query(filter: #Predicate<Collection> { collection in
        collection.typeName == "Discipulado"
    }, sort: \Collection.title, order: .forward) private var collectionItems: [Collection]
    
    var body: some View {
        VStack(spacing: 0) {
            TopBarScreen(title: "Capacitaciones")
            ScrollView(.vertical) {
                VStack(spacing: 24) {
                    ForEach(collectionItems) { discipleship in
                        Button {
                            router.navigateTo(.collection(id: discipleship.id, cols: 1))
                        } label: {
//                            DiscipleshipCard(title: discipleship.title, image: Image(.preview2))
                            CollectionCard(collection: discipleship)
                        }
                    }
                }
                .padding(.bottom)
            }
        }
        .scrollIndicators(.hidden)
        .padding(.horizontal)
        .background(.customBlack)
        .onAppear(perform: {
            getCollections()
        })
        .enableInjection()
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
    private func getCollections() {
//        if collectionsRepository.series.isEmpty {
//            Task {
//                do {
//                    try await collectionsRepository.getCollections()
//                } catch {
//                    print(error)
//                    self.errorMessage = "No se han podido recuperar las capacitaciones"
//                }
//            }
//        }
    }
}

#Preview {
    DiscipleshipListScreen()
}
