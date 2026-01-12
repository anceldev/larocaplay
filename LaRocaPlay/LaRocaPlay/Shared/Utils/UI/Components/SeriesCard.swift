//
//  SeriesCard.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 28/12/25.
//

import SwiftUI

struct SeriesCard: View {
    @Environment(AppRouter.self) var router
    var body: some View {
        Button {
            router.navigateTo(.collections("Serie", "Series"))
        } label: {
            Image(.bgSeries)
                .resizable()
                .scaledToFill()
                .blur(radius: 2)
                .overlay {
                    Text("Series")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: .black, radius: 5, x: 0, y: 0)
                }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(.brown)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.player))
        .enableInjection()
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}
