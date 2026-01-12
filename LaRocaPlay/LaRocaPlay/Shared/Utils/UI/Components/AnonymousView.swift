//
//  AnonymousView.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 24/12/25.
//

import SwiftUI

struct AnonymousView: View {
    @Binding var showAuthSheet: Bool
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundStyle(.gray)
            
            Text("Únete a nuestra comunidad")
                .font(.headline)
            
            Text("Regístrate para proteger tu suscripción y acceder desde cualquier dispositivo.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            
            Button("Crear cuenta o Iniciar sesión") {
                showAuthSheet = true
            }
            .buttonStyle(.capsuleButton(color: .customRed, textColor: .white))
        }
        .padding(18)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .enableInjection()
    }
#if DEBUG
@ObserveInjection var forceRedraw
#endif
}
