//
//  ResetPasswordScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 30/12/25.
//

import SwiftUI

struct ResetPasswordScreen: View {
    @Environment(AuthManager.self) var authManager
    @State private var email: String = ""
    @Binding var authMode: AuthMode
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("¿Has olvidado tu contraseña?")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.dirtyWhite)
                        .multilineTextAlignment(.center)
                    Text("Restablecer contraseña")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                }
            }
            VStack(alignment: .leading, spacing: 24) {
                HStack(spacing: 0) {
                    Text("Correo")
                        .foregroundStyle(.white)
                    Text("*")
                        .foregroundStyle(.customRed)
                }
                .font(.system(size: 14))
                TextField("email", text: $email, prompt:Text("Correo electrónico").foregroundStyle(.dirtyWhite.opacity(0.3)))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .foregroundStyle(.white)
                    .tint(.white)
                    .submitLabel(.send)
                    .textFieldStyle(.customTextFieldStyle)
            }
            VStack {
                Button {
                    print("Send password request")
                } label: {
                    Text("Restablecer contraseña")
                }
                .buttonStyle(.capsuleButton(.customRed))
            }
            VStack(spacing: 16) {
                VStack {
                    Button {
                        self.email = ""
                        withAnimation(.easeIn) {
                            self.authMode = .signup
                        }
                    } label: {
                        Text("Iniciar sesión")
                            .fontWeight(.bold)
                    }
                    .buttonStyle(.plain)
                    .disabled(authManager.isLoading)
                }
                .font(.system(size: 14))
                .foregroundStyle(.dirtyWhite)
            }
        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(.customBlack)
        .enableInjection()
        
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}
