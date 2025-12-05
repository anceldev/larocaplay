//
//  SeriesScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 12/10/25.
//

import SwiftUI

struct TopBarScreen: View {
    @Environment(AppRouter.self) var router
    let title: String
    let backButton: Bool
    
    init(title: String, _ backButton: Bool = false) {
        self.title = title
        self.backButton = backButton
    }
    var body: some View {
        ZStack {
            HStack {
                if backButton {
                    Button {
                        router.popNavigation()
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                                .foregroundStyle(.customRed)
                        }
                    }
                }
                Spacer()
            }
            HStack {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 6)
    }
}

struct SeriesScreen: View {
    @Environment(AppRouter.self) var router
    @Environment(CollectionRepository.self) var seriesRepository
    
    @State private var errorMessage: String? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            TopBarScreen(title: "Series", true)
            if seriesRepository.series.count == 0 {
                Text("No hay ninguna serie añadida")
            } else {
                ScrollView(.vertical) {
                    VStack(spacing: 24) {
                        ForEach(seriesRepository.series.filter({ $0.collectionType.id == 2 })) { serie in
                            Button {
                                router.navigateTo(.collection(id: serie.id, cols: 2))
                            } label: {
                                CollectionCard(collection: serie)
                            }
                            
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
        .background(.customBlack)
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
    
    private func getCollections() async {
        do {
            if seriesRepository.series.isEmpty {
                try await self.seriesRepository.getCollections()
            }
        } catch {
            print(error)
            self.errorMessage = "No se han podido recuperar las colecciones"
        }
    }
}

//#Preview {
//    SeriesScreen()
//}
