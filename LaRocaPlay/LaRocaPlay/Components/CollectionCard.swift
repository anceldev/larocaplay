//
//  EventsCard.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 15/9/25.
//

import SwiftUI

struct CollectionCard: View {
    @Environment(AppRouter.self) var router
    
    var collection: PreachCollection
    
    var body: some View {
        VStack {
            Button {
//                router.navigateTo(.series)
                router.navigateTo(.collection(id: collection.id, cols: 1))
            } label: {
                ZStack {
                    Image(.bgSeries)
                        .resizable()
                        .scaledToFill()
                        .blur(radius: 2)
                    VStack(spacing: 16) {
                        Text(collection.title)
                            .font(.system(size: 24, weight: .bold))
                        if let description = collection.description {
                            Text(description)
                                .font(.system(size: 12, weight: .medium))
                                .padding(.horizontal, 32)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .foregroundStyle(.white)
                    .font(.system(size: 24, weight: .semibold))
                    .shadow(color: .black,radius: 5)
                }
            }
        }
        .frame(maxWidth: .infinity)
//        .frame(minHeight: 200)
        .frame(maxHeight: 180)
        .background(.indigo)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .enableInjection()
    }
    
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}
//
//#Preview {
//    CollectionCard()
//}

