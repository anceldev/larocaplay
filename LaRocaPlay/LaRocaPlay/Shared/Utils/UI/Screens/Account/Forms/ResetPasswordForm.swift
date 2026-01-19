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
//    @Environment(ToastManager.self) var toasts
    @Environment(\.dismiss) var dismiss
    
    @State private var showPopover = false
    @State private var formModel = ResetPasswordFormModel()
    
    
    var isFormValid: Bool {
        !authManager.isLoading && formModel.isValid
    }

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("¿Has olvidado tu contraseña o quieres cambiarla?")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.dirtyWhite)
                        .multilineTextAlignment(.center)
                    Text("Restablecer contraseña")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                }
            }
            VStack(alignment: .leading) {
                HStack(spacing: 0) {
                    Text("Correo")
                        .foregroundStyle(.white)
                    Text("*")
                        .foregroundStyle(.customRed)
                }
                .font(.system(size: 14))
                TextField("email", text: $formModel.email, prompt:Text("Correo electrónico")
                    .foregroundStyle(.dirtyWhite.opacity(0.3)))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)
                    .foregroundStyle(.white)
                    .tint(.white)
                    .submitLabel(.send)
                    .customCapsule(!formModel.email.isEmpty)
                    .withValidation(formModel.$email)
 
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
            await authManager.resetPassword(for: formModel.email)
            dismiss()
        }
    }
}
