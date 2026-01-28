//
//  SignInForm.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 12/9/25.
//

//import GoogleSignInSwift
import FirebaseMessaging
import SwiftUI

// TODO: Añadir validadores a los texfields, para que se vean errores cuando no cumplen el regex.

struct SignInForm: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) var authManager
    
    @State private var formModel = SigninFormModel()
    
    private enum FocusedField {
        case email, password
    }
    
    @FocusState private var focusedField: FocusedField?

    @Binding var authMode: AuthMode
    
    var isFormValid: Bool {
        !authManager.isLoading &&
        formModel.isValid
    }
    
    var body: some View {
        VStack(spacing: 32) {
            ScrollView(.vertical) {
                VStack(spacing: 12) {
                    Text("Bienvenido de nuevo")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.appLabel.primary)
                        .multilineTextAlignment(.center)
                    HStack(spacing: 4) {
                        Text("Inicia sesión")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.appLabel.primary)
                        Text("con tu cuenta.")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundStyle(.appLabel.secondary)
                    }
                }
                .padding(.top, 24)
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        VStack(alignment: .leading) {
                            HStack(spacing: 0) {
                                Text("Correo")
                                    .foregroundStyle(.appLabel.primary)
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
                                .foregroundStyle(.appLabel.primary)
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
                                    .foregroundStyle(.white)
                                Text("*")
                                    .foregroundStyle(.customRed)
                            }
                            .font(.system(size: 14))
                            
                            SecureField("pasword", text: $formModel.password, prompt: Text("Contraseña").foregroundStyle(.dirtyWhite.opacity(0.3)))
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .customCapsule(focusedField == .password || !formModel.password.isEmpty)
                                .focused($focusedField, equals: .password)
                                .foregroundStyle(.appLabel.primary)
                                .tint(.white)
                                .submitLabel(.go)
                                .animation(.easeInOut, value: focusedField)
                                .onSubmit {
                                    focusedField = nil
                                }
                                .withValidation(formModel.$password)
                            Button {
                                withAnimation(.easeInOut) {
                                    self.authMode = .resetPassword
                                }
                            } label: {
                                Text("He olvidad mi contraseña")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundStyle(.appLabel.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            
                        }
                    }
                    if let errorMessage = authManager.errorMessage {
                        FormErrorMessage(errorMessage: errorMessage)
                    }
                    VStack {
                        Button {
                            self.focusedField = nil
                            authManager.errorMessage = nil
                            signInAction()
                        } label: {
                            if authManager.isLoading {
                                ProgressView()
                                    .tint(.dirtyWhite)
                            } else {
                                Text("Iniciar sesión")
                            }
                        }
                        .buttonStyle(.capsuleButton(color: isFormValid ? Theme.Button.normal : Theme.Button.disabled))
                        .disabled(!isFormValid)
                        .animation(.easeInOut, value: isFormValid)
                    }
                    VStack(spacing: 24) {
                        HStack {
                            Rectangle()
                                .frame(height: 1)
                                .background(.dirtyWhite)
                                .frame(maxWidth: 70)
                            Text("O inicia sesión con")
                            Rectangle()
                                .frame(height: 1)
                                .background(.dirtyWhite)
                                .frame(maxWidth: 70)
                        }
                        HStack(spacing: 24) {
                            Button {
                                print("Apple signin")
                            } label: {
                                Image(.logoSIWALogoOnlyBlack)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 44)
                                    .mask(RoundedRectangle(cornerRadius: 12))
                            }
                            Button {
                                print("Google signin")
                            } label: {
                                Image(.iosNeutralRdNa)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 44)
                            }
                        }
                    }
                    VStack(spacing: 16) {
                        VStack {
                            Button {
                                signinAsGuest()
                            } label: {
                                Text("Continuar como invitado")
                                    .fontWeight(.bold)
                            }
                            .buttonStyle(.plain)
                            .disabled(authManager.isLoading)
                        }
                        .font(.system(size: 14))
                        .foregroundStyle(.appLabel.secondary)
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
                        .foregroundStyle(.appLabel.secondary)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .animation(.easeIn, value: authManager.errorMessage)
        .background(.appBackground.primary)
        .onChange(of: focusedField) { oldValue, newValue in
            switch oldValue {
            case .email: formModel.validateEmail()
            case .password: formModel.validatePassword()
            default: break
            }
        }
        .enableInjection()
        .onDisappear {
            self.authManager.errorMessage = nil
        }
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
    private func cleanForm() {
        self.formModel.email = ""
        self.formModel.password = ""
    }
    private func signInAction() {
        Task {
            await authManager.signIn(email: formModel.email, password: formModel.password)
            if authManager.isAuthenticated {
                dismiss()
            }
        }
    }
    private func signinAsGuest() {
        Task {
            await authManager.startGuestSession()
        }
    }
    private func handleGoogleSignIn() {
        print("Siging in with google")
    }
}
