//
//  ResetPasswordScreen.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 6/12/25.
//

import SwiftUI

struct ResetPasswordScreen: View {
    @Environment(AuthService.self) var auth
    @State private var email: String = ""
    @Binding var authMode: AuthMode
    //    @FocusState var focused
    @Binding var isLoading: Bool
    @State private var errorMessage: String? = nil
    
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
                    if isLoading {
                        ProgressView()
                            .tint(.dirtyWhite)
                    } else {
                        Text("Restablecer contraseña")
                    }
                }
                .buttonStyle(.capsuleButton(.customRed))
                Button {
                    self.authMode = .login
                } label: {
                    Text("Inicier sesión")
                }
            }
        }
    }
    private func sendPasswordRequest() {
        Task {
            self.isLoading = true
            self.errorMessage = nil
            do {
                try Validations.shared.isValidEmail(self.email)
                try await auth.resetPassword(email)
            } catch {
                print(error)
                self.errorMessage = error.localizedDescription
            }
            self.isLoading = false
        }
    }
}

#Preview {
    @Previewable @State var email: String = ""
    @Previewable @State var isLoading: Bool = false
    @Previewable @State var errorMesage: String = ""
    @Previewable @State var authMode: AuthMode = .signup

    ResetPasswordScreen(authMode: $authMode, isLoading: $isLoading)
        .environment(AuthService())
        .background(.customBlack)
}
