//
//  ResetPasswordForm.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 31/12/25.
//

import SwiftUI

// TODO: Añadir validadores a los texfields, para que se vean errores cuando no cumplen el regex.

struct ResetPasswordForm: View {
    @Environment(AuthManager.self) var authManager
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    
    @State private var showPopover = false
    @State private var formModel = ResetPasswordFormModel()
    
    
    var isFormValid: Bool {
        !authManager.isLoading && formModel.isValid
    }
    
    var userExists: Bool {
        authManager.currentUserProfile != nil ? true : false
    }

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("¿Has olvidado tu contraseña o quieres cambiarla?")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.appLabel.secondary)
                        .multilineTextAlignment(.center)
                    Text("Restablecer contraseña")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.appLabel.primary)
                        .multilineTextAlignment(.center)
                }
            }
            VStack(alignment: .leading) {
                HStack(spacing: 0) {
                    Text("Correo")
                        .foregroundStyle(.appLabel.primary)
                    Text("*")
                        .foregroundStyle(.customRed)
                }
                .font(.system(size: 14))
                TextField("email", text: $formModel.email, prompt:Text("Correo electrónico")
                    .foregroundStyle(.dirtyWhite.opacity(0.3)))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)
                    .foregroundStyle(.appLabel.primary)
                    .tint(.white)
                    .submitLabel(.send)
                    .customCapsule(!formModel.email.isEmpty)
                    .withValidation(formModel.$email)
                    .disabled(userExists)
 
            }
            VStack {
                Button {
                    showPopover.toggle()
                } label: {
                    Text("Enviar correo")
                }
                .buttonStyle(.capsuleButton(color: isFormValid ? Theme.Button.normal : Theme.Button.disabled))
                .disabled(!isFormValid)
                .animation(.easeIn, value: isFormValid)
            }
        }
        .onAppear(perform: {
            if userExists {
                formModel.email = authManager.currentUserProfile!.email!
            }
        })
        .popView(
            isPresented: $showPopover,
            content: {
                CustomDialog(
                    show: $showPopover,
                    dialogType: .updatePassword,
                    onAccept: sendResetPasswordLink
                )
        })
        .enableInjection()
    }
#if DEBUG
@ObserveInjection var forceRedraw
#endif
    private func sendResetPasswordLink() async {
        Task {
            await NotificationManager.shared.unsuscribeFromPrivateCollections(context: context)
            await authManager.ressetPasswordRequest(for: formModel.email)
            dismiss()
        }
    }
}
