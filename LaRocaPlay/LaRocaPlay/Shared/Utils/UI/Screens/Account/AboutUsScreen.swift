//
//  AboutUsScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 10/1/26.
//

import SwiftUI

struct AboutUsScreen: View {
    var body: some View {
        VStack {
            TopBarScreen(title: "Sobre Nosotros", true)
            ScrollView(.vertical) {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nuestra Visión como iglesia")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(.white)
                        Text("Somos una iglesia con una visión pastoral, relacional que vivimos la misión en fe, esperanza y amor a las naciones, para que todos sean pastoreados y que ninguno se pierda. Siendo, haciendo, equipando y plantando discipulos a través de las relaciones en células de amistad. Esta es nuestra visión y propósito.")
                            .foregroundStyle(.dirtyWhite)
                            .font(.system(size: 18))
                    }
                    VStack(spacing: 8) {
                        Text("Puedes encontrarnos en")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .scrollIndicators(.hidden)
        }
        .padding(18)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.appBackground.primary)
        .enableInjection()
    }
#if DEBUG
@ObserveInjection var forceRedraw
#endif
}

#Preview {
    AboutUsScreen()
        .environment(AppRouter(initialTab: .home))
        .preferredColorScheme(.dark)
}
