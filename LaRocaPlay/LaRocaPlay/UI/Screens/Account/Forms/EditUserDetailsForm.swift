//
//  EditUserDetailsForm.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 31/12/25.
//

import SwiftUI

struct EditUserDetailsForm: View {
    @State private var email = ""
    @State private var displayName = ""
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Actualizar datos")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.dirtyWhite)
                        .multilineTextAlignment(.center)
                    Text("Introduce nuevos datos")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                }
            }
            VStack(spacing: 16) {
                VStack(alignment: .leading) {
                    HStack(spacing: 0) {
                        Text("Nombre")
                            .foregroundStyle(.white)
//                        Text("*")
//                            .foregroundStyle(.customRed)
                    }
                    .font(.system(size: 14))
                    TextField("email", text: $displayName, prompt:Text("Correo electrónico")
                        .foregroundStyle(.dirtyWhite.opacity(0.3)))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .foregroundStyle(.white)
                    .tint(.white)
                    .submitLabel(.send)
                    .customCapsule(!displayName.isEmpty)
                }
                VStack(alignment: .leading) {
                    HStack(spacing: 0) {
                        Text("Correo")
                            .foregroundStyle(.white)
                        Text("*")
                            .foregroundStyle(.customRed)
                    }
                    .font(.system(size: 14))
                    TextField("email", text: $email, prompt:Text("Correo electrónico")
                        .foregroundStyle(.dirtyWhite.opacity(0.3)))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .foregroundStyle(.white)
                    .tint(.white)
                    .submitLabel(.send)
                    .customCapsule(!email.isEmpty)
                }
            }
            VStack {
                Button {
                    print("Send password request")
                } label: {
                    Text("Restablecer contraseña")
                }
                .buttonStyle(.capsuleButton(.customRed))
            }
        }
        .padding(Theme.Padding.normal)
        .enableInjection()
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
    private func updateUserDetails () {
        // TODO: Plantar bien todas las opciones antes, no esta claro el camino.
        // TODO: Gestionar edicion de detalles de usuario.
        // TODO: Si actualiza el correo, cerrar todas las sesiones asociadas a este usuario?
    }
}
