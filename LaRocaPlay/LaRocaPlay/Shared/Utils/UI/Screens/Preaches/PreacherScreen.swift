//
//  PreacherScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 13/9/25.
//

import SwiftUI


struct PreacherScreen: View {
    @Environment(AppRouter.self) var router
    let preacher: PreacherDTO
     var body: some View {
        VStack {
            Image(.previewPreacher)
                .resizable()
                .aspectRatio(1/1, contentMode: .fit)
                .clipShape(.circle)
                .padding(.horizontal, 32)
                .shadow(color: .gray, radius: 5)
            // TODO: Hacer bien el diseño de esta vista
            Text(preacher.name)
            Text(preacher.role.name)
            Spacer()
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
        .padding()
        .enableInjection()
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
    private func getPreaches() {
        // TODO: Hacer fetching de las predicaciones de este predicador.
    }
}
