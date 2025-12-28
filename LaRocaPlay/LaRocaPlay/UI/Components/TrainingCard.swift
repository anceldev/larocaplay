//
//  TrainingCard.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 15/9/25.
//

import SwiftUI

struct TrainingCard: View {
    @Environment(AppRouter.self) var router
    
    var body: some View {
        VStack {
            Button {
            } label: {
                ZStack {
//                    Image(
                    Image(.defaultDiscipleship)
                        .resizable()
                    Text("Capacitaciones")
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .enableInjection()
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}
