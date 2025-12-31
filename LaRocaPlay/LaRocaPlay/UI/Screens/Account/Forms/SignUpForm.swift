//
//  SignUpForm.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 12/9/25.
//

import SwiftUI
import Supabase

struct SignUpForm: View {
    @Environment(\.dismiss) var dismiss
    @Environment(AuthManager.self) var authManager
    private enum FocusedField {
        case email, password, confirmPassword
    }
    
    @FocusState private var focusedField: FocusedField?
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @Binding var authMode: AuthMode
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Bienvenido a")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.dirtyWhite)
                        .multilineTextAlignment(.center)
                    Text("La Roca Play")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                }
                HStack(spacing: 4) {
                    Text("Crea tu cuenta para empezar.")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.dirtyWhite)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            }
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    VStack(alignment: .leading) {
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
                            .customCapsule(focusedField == .email || !email.isEmpty)
                            .focused($focusedField, equals: .email)
                            .foregroundStyle(.white)
                            .tint(.white)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .password
                            }
                            .animation(.easeInOut, value: focusedField)
                    }
                    
                    VStack(alignment: .leading) {
                        HStack(spacing: 0) {
                            Text("Contraseña")
                                .foregroundStyle(.white)
                            Text("*")
                                .foregroundStyle(.customRed)
                        }
                        .font(.system(size: 14))
                        
                        SecureField("pasword", text: $password, prompt: Text("Contraseña").foregroundStyle(.dirtyWhite.opacity(0.3)))
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .customCapsule(focusedField == .password || !password.isEmpty)
                            .focused($focusedField, equals: .password)
                            .foregroundStyle(.white)
                            .tint(.white)
                            .submitLabel(.go)
                            .animation(.easeInOut, value: focusedField)
                            .onSubmit {
                                focusedField = nil
                            }
                    }
                    VStack(alignment: .leading) {
                        HStack(spacing: 0) {
                            Text("Confirmar contraseña")
                                .foregroundStyle(.white)
                            Text("*")
                                .foregroundStyle(.customRed)
                        }
                        .font(.system(size: 14))
                        
                        SecureField("password", text: $confirmPassword, prompt: Text("Repite la contraseña").foregroundStyle(.dirtyWhite.opacity(0.3)))
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .customCapsule(focusedField == .confirmPassword || !confirmPassword.isEmpty)
                            .focused($focusedField, equals: .confirmPassword)
                            .foregroundStyle(.white)
                            .tint(.white)
                            .submitLabel(.go)
                            .animation(.easeInOut, value: focusedField)
                            .onSubmit {
                                focusedField = nil
                            }
                    }
                }
                Button {
                    signUpAction()
                } label: {
                    if authManager.isLoading {
                        ProgressView()
                            .tint(.dirtyWhite)
                    } else {
                        Text("Registrarse")
                    }
                }
                .buttonStyle(.capsuleButton(.customRed))
                .disabled(authManager.isLoading)
                VStack(spacing: 16) {
                    VStack {
                        Text("Ya tengo cuenta")
                            .fontWeight(.light)
                        Button {
                            withAnimation(.easeIn) {
                                self.authMode = .login                                
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
        }
////        .frame(maxHeight: .infinity)
//        .background(.customBlack)
        .enableInjection()
    }
    private func cleanForm() {
        self.email = ""
        self.password = ""
        self.confirmPassword = ""
    }
    private func signUpAction() {
        Task {
            await authManager.signUp(email: email, password: password, confirmPassword: confirmPassword)
            dismiss()
        }
    }
    
    private func checkPasswordsField() throws {
        if self.password == self.confirmPassword {
            try Validations.shared.isValidPassword(self.password)
            return
        }
        throw SignUpError.passwordsDoNotMatch
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}
