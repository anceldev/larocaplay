//
//  CongressesScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 15/9/25.
//

import SwiftUI

struct CongressesScreen: View {
    @Environment(AppRouter.self) var router
    var body: some View {
        VStack {
            Text("Esta es la pantalla para congresos y eventos")
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    router.popNavigation()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Atrás")
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
//
//#Preview {
//    CongressesScreen()
//}
