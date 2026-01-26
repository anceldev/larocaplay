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
        VStack(spacing: 32) {
//            Image(systemName: "person.fill")
            Image(.avatar)
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundStyle(.gray)
            VStack(spacing: 8) {
                Text("Únete a nuestra comunidad")
                //                .font(.headline)
                    .font(.system(size: 18, weight: .semibold))
                
                Text("Regístrate para proteger tu suscripción y acceder desde cualquier dispositivo.")
                //                .font(.subheadline)
                    .font(.system(size: 14))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 32)
            }
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
