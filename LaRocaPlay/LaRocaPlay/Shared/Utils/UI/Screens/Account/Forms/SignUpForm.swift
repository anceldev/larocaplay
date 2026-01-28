//
//  SignUpForm.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 12/9/25.
//

import FirebaseMessaging
import SwiftUI
import Supabase

// TODO: Añadir validadores a los texfields, para que se vean errores cuando no cumplen el regex.
struct SignUpForm: View {
    @Environment(\.dismiss) var dismiss
    @Environment(AuthManager.self) var authManager
    
    @State private var formModel = SignupFormModel()
    
    private enum FocusedField {
        case email, password, confirmPassword
    }
    
    @FocusState private var focusedField: FocusedField?
    
    @Binding var authMode: AuthMode
    
    var isFormValid: Bool {
        !authManager.isLoading &&
        formModel.isValid &&
        formModel.password == formModel.confirmPassword
    }
    var matchPasswordsError: String? {
        guard !formModel.confirmPassword.isEmpty else { return nil }
        return formModel.password == formModel.confirmPassword ? nil : "Las contraseñas no coinciden."
    }
    
    var body: some View {
        VStack(spacing: 32) {
            ScrollView(.vertical) {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("Bienvenido a")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.appLabel.secondary)
                            .multilineTextAlignment(.center)
                        Text("La Roca Play")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundStyle(.appLabel.primary)
                            .multilineTextAlignment(.center)
                    }
                    HStack(spacing: 4) {
                        Text("Crea tu cuenta para empezar.")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.appLabel.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                }
                if let errorMessage = authManager.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.red)
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
                            TextField("email", text: $formModel.email, prompt:Text("Correo electrónico").foregroundStyle(.dirtyWhite.opacity(0.3)))
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .keyboardType(.emailAddress)
                                .customCapsule(focusedField == .email || !formModel.email.isEmpty)
                                .focused($focusedField, equals: .email)
                                .foregroundStyle(.white)
                                .tint(.white)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .password
                                }
                                .animation(.easeInOut, value: focusedField)
                                .withValidation(formModel.$email)
                        }
                        
                        VStack(alignment: .leading) {
                            HStack(spacing: 0) {
                                Text("Contraseña")
                                    .foregroundStyle(.appLabel.primary)
                                Text("*")
                                    .foregroundStyle(.customRed)
                            }
                            .font(.system(size: 14))
                            
                            SecureField("pasword", text: $formModel.password, prompt: Text("Contraseña").foregroundStyle(.dirtyWhite.opacity(0.3)))
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .customCapsule(focusedField == .password || !formModel.password.isEmpty)
                                .focused($focusedField, equals: .password)
                                .foregroundStyle(.white)
                                .tint(.white)
                                .submitLabel(.go)
                                .animation(.easeInOut, value: focusedField)
                                .onSubmit {
                                    focusedField = nil
                                }
                                .withValidation(formModel.$password)
                        }
                        VStack(alignment: .leading) {
                            HStack(spacing: 0) {
                                Text("Confirmar contraseña")
                                    .foregroundStyle(.appLabel.primary)
                                Text("*")
                                    .foregroundStyle(.customRed)
                            }
                            .font(.system(size: 14))
                            
                            SecureField("password", text: $formModel.confirmPassword, prompt: Text("Repite la contraseña").foregroundStyle(.dirtyWhite.opacity(0.3)))
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .customCapsule(focusedField == .confirmPassword || !formModel.confirmPassword.isEmpty)
                                .focused($focusedField, equals: .confirmPassword)
                                .foregroundStyle(.white)
                                .tint(.white)
                                .submitLabel(.go)
                                .animation(.easeInOut, value: focusedField)
                                .onSubmit {
                                    focusedField = nil
                                }
                                .withValidation(formModel.$confirmPassword)
                        }
                    }
                    if let matchPasswordsError {
                        Text(matchPasswordsError)
                            .foregroundStyle(.red)
                            .font(.system(size: 14))
                    }
                    if let errorMessage = authManager.errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.system(size: 14))
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
                    .buttonStyle(.capsuleButton(color: isFormValid ? Theme.Button.normal : Theme.Button.disabled))
                    .disabled(!isFormValid)
                    .animation(.easeInOut, value: isFormValid)
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
                        .foregroundStyle(.appLabel.secondary)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .onChange(of: focusedField) { oldValue, newValue in
            switch oldValue {
            case .email: formModel.validateEmail()
            case .password: formModel.validatePassword()
            case .confirmPassword: formModel.validateConfirmPassword()
            default: break
            }
        }
        .enableInjection()
    }
    private func cleanForm() {
        self.formModel.email = ""
        self.formModel.password = ""
        self.formModel.confirmPassword = ""
    }
    private func signUpAction() {
        Task {
            await authManager.signUp(
                email: formModel.email,
                password: formModel.password,
                confirmPassword: formModel.confirmPassword
            )
            if authManager.isAuthenticated {
                    dismiss()
            }
        }
    }

#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}
