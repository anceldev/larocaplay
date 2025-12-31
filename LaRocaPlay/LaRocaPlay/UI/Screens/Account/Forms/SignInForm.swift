//
//  SignInForm.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 12/9/25.
//

import GoogleSignInSwift
import SwiftUI

struct SignInForm: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) var authManager
    
    private enum FocusedField {
        case email, password
    }
    
    @FocusState private var focusedField: FocusedField?
    
    @State private var email: String = ""
    @State private var password: String = ""
    @Binding var authMode: AuthMode
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 12) {
                Text("Bienvenido de nuevo")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                HStack(spacing: 4) {
                    Text("Inicia sesión")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("con tu cuenta.")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.dirtyWhite)
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
                        Button {
                            withAnimation(.easeInOut) {
                                self.authMode = .resetPassword
                            }
                        } label: {
                            Text("He olvidad mi contraseña")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(.dirtyWhite)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)

                    }
                }
                VStack {
                    Button {
                        signInAction()
                    } label: {
                        if authManager.isLoading {
                            ProgressView()
                                .tint(.dirtyWhite)
                        } else {
                            Text("Iniciar sesión")
                        }
                    }
                    .buttonStyle(.capsuleButton(.customRed))
                    .disabled(authManager.isLoading)
                    
                }
                VStack(spacing: 16) {
                    VStack {
                        Text("¿Todavía no tienes una cuenta?")
                            .fontWeight(.light)
                        
                        Button {
                            cleanForm()
                            withAnimation(.easeIn) {
                                self.authMode = .signup
                            }
                        } label: {
                            Text("Regístrate")
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
//        .frame(maxHeight: .infinity)
        .background(.customBlack)
        .enableInjection()
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
    private func cleanForm() {
        self.email = ""
        self.password = ""
    }
    private func signInAction() {
        Task {
            await authManager.signIn(email: email, password: password)
            dismiss()
        }
    }
    private func handleGoogleSignIn() {
        print("Siging in with google")
    }
}
