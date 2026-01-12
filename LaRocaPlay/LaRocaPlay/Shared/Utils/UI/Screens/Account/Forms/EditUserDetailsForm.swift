//
//  EditUserDetailsForm.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 31/12/25.
//

import SwiftUI

// TODO: Añadir validadores a los texfields, para que se vean errores cuando no cumplen el regex.

struct EditUserDetailsForm: View {
    
    @Environment(AuthManager.self) var authManager
    
    let currentEmail: String
    let currentName: String
    
    @State private var email: String
    @State private var displayName: String
    @State private var showConfirmationDialog = false
    
    var isFormValid: Bool {
        authManager.isLoading || displayName.isEmpty
    }
    
    init(email: String, displayName: String) {
        self.currentEmail = email
        self.currentName = displayName
        self._email = State(initialValue: email)
        self._displayName = State(initialValue: displayName)
    }
    
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
                    if currentEmail != email {
                        showConfirmationDialog.toggle()
                    } else {
                        updateName()
                    }
                } label: {
                    Text("Actualizar")
                }
                .buttonStyle(.capsuleButton(color: isFormValid ? Theme.Button.normal : Theme.Button.disabled))
                .disabled(!isFormValid)
                .animation(.easeInOut, value: isFormValid)
            }
        }
        .popView(
            isPresented: $showConfirmationDialog,
            content: {
                CustomDialog(
                    show: $showConfirmationDialog,
                    dialogType: .updateInfo,
                    onAccept: updateUserDetails
                )                
        })
        .padding(Theme.Padding.normal)
//        .background(.customBlack)
        .enableInjection()
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
    private func updateName() {
        print("Update name")
    }
    private func updateUserDetails() async {
        // TODO: Plantar bien todas las opciones antes, no esta claro el camino.
        // TODO: Gestionar edicion de detalles de usuario.
        // TODO: Si actualiza el correo, cerrar todas las sesiones asociadas a este usuario?
        print("Update user deatils")
    }
}
