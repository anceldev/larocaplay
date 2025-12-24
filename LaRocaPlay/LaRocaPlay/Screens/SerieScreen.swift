//
//  SeriesScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 12/10/25.
//

import SwiftUI

struct SerieScreen: View {
    @Environment(CollectionRepository.self) var seriesRepository
    @State private var searchQuery = ""
    
    let serieId: Int
//    var serie: Serie {
//        seriesRepository.series.first { $0.id == serieId }!
//    }
    @State var lessons: [PreachDTO] = []
    
    var body: some View {
        VStack {
//            VStack {
//                Text(serie.name)
//                    .font(.system(size: 20, weight: .bold))
//                    .foregroundStyle(.dirtyWhite)
//                Text("\(lessons.count) lecciones")
//            }
//            .padding(.vertical, 8)
//            VStack(spacing: 16) {
//                ScrollView(.vertical) {
//                    ItemsList(preaches: lessons, cols: 1)
//                }
//                .padding(.horizontal, 20)
//                .scrollIndicators(.hidden)
//            }
        }
        .background(.customBlack)
//        .onAppear {
//            Task {
//                await getLessons()
//            }
//        }
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
    private func getLessons() async {
//        do {
//            self.lessons = try await seriesRepository.getLessons(serieId: serieId)
//            
//        } catch {
//            print(error.localizedDescription)
//        }
    }
}

#Preview {
    SeriesScreen()
}
