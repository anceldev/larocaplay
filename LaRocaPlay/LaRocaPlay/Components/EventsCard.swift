//
//  EventsCard.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 15/9/25.
//

import SwiftUI

struct EventsCard: View {
    @Environment(AppRouter.self) var router
    
    var body: some View {
        VStack {
            Button {
                router.navigateTo(.congresses)
            } label: {
                ZStack {
                    Image(.bgCongresses)
                        .resizable()
                        .scaledToFit()
                        .blur(radius: 3)
                    VStack {
                        Text("Eventos y congresos")
                    }
                    .foregroundStyle(.white)
                    .font(.system(size: 24, weight: .semibold))
                    .shadow(color: .black,radius: 5)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 200)
        .background(.indigo)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .enableInjection()
    }
    
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}

#Preview {
    EventsCard()
}
