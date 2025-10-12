//
//  DiscipleshipScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 15/9/25.
//

import SwiftUI

// TODO: Crear una carpeta 'resources' en Storage, para que la imagen de carga aquí sea dinámica, y tener una imagen por defecto en caso de que no se pueda obtener la remota

struct DiscipleshipListScreen: View {
    @Environment(AppRouter.self) var router
    
    let role: UserRole
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                Button {
                    
                } label: {
                    DiscipleshipCard(title: "Discipulado 1", image: Image(.preview2))
                }
                    
                DiscipleshipCard(title: "Discipulado 2", image: Image(.preview2))
                if role != .member {
                    TrainingCard()
                }
            }
        }
        .scrollIndicators(.hidden)
        .padding(.horizontal)
        .enableInjection()
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}

#Preview {
    DiscipleshipListScreen(role: .member)
}
