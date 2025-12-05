//
//  CollectionScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 2/12/25.
//

import SwiftUI

struct CollectionScreen: View {
    @Environment(CollectionRepository.self) var collections
    var collectionId: Int
    
    var collection: PreachCollection? {
        guard let collection = collections.series.first (where: { $0.id == collectionId }) else {
            return nil
        }
        return collection
    }
    
    var body: some View {
        VStack {
            TopBarScreen(title: (collection != nil ? collection!.title : ""), true)
            PreachCollectionScreen(collectionId: collectionId)
        }
        .padding(.horizontal)
        .background(.customBlack)
        .enableInjection()
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}
