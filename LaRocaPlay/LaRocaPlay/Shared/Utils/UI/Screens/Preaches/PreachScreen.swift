//
//  PreachScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 2/8/25.
//

import MediaPlayer
import RevenueCatUI
import SwiftData
import SwiftUI

enum LoadingState {
    case idle
    case loading
    case success
    case failed(Error)
}

struct PreachScreen: View {
////    @State private var isFetching = false
//    @State private var loadingState: LoadingState = .idle
////    @Query private var preaches: [Preach]
//    @Query private var collectionItems: [CollectionItem]
//    
//    init(for itemId: Int) {
//        let predicate = #Predicate<CollectionItem> { $0.id == itemId }
//        self._collectionItems = Query(filter: predicate)
//    }
//
    let preach: Preach
    var body: some View {
        VStack(alignment: .leading) {
//            PreachDetailView(preach: preach)
        }
        .padding(.horizontal)
        .navigationBarBackButtonHidden(true)
        .background(.customBlack)
        .enableInjection()
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
    @ViewBuilder
    func NoPreachFound() -> some View {
        Text("No se ha podido encontrar la predicación que estás buscando.")
    }
}
