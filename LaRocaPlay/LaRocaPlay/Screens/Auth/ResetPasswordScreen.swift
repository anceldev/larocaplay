//
//  ResetPasswordScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 6/12/25.
//

import SwiftUI

struct ResetPasswordScreen: View {
//    @Environment(AuthService.self) var auth
    @Environment(AuthManager.self) var authManager
    @State private var email: String = ""
    
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

                Button {
                    sendPasswordRequest()
                } label: {
                    Text("Restablecer contraseña")
                }
                .buttonStyle(.capsuleButton(.customRed))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(18)
        .background(.customBlack)
        .enableInjection()
        
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
    private func sendPasswordRequest() {
        // TODO: Send password request
    }
}
