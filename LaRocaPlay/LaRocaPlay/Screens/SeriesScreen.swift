//
//  SeriesScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 12/10/25.
//

import SwiftUI

struct SeriesScreen: View {
    @Environment(AppRouter.self) var router
    @Environment(SeriesRepository.self) var seriesRepository
    var body: some View {
        VStack {
            Text("Series screen")
            if seriesRepository.series.count == 0 {
                Text("No hay ninguna serie añadida")
            } else {
                ScrollView(.vertical) {
                    VStack(spacing: 24) {
                        ForEach(seriesRepository.series) { serie in
                            Button {
                                router.navigateTo(.serie(id: serie.id))
                            } label: {
                                
                                VStack(alignment: .center, spacing: 8) {
                                    Text(serie.name)
                                        .font(.system(size: 24, weight: .bold))
                                    if let serieDescription = serie.description {
                                        Text(serieDescription)
                                            .font(.system(size: 16, weight: .medium))
                                            .padding(.horizontal, 32)
                                            .multilineTextAlignment(.center)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}

//#Preview {
//    SeriesScreen()
//}
