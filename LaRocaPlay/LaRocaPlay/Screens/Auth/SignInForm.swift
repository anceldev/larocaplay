//
//  SignInForm.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 12/9/25.
//

import SwiftUI

struct SignInForm: View {
//    @Environment(AuthService.self) var auth
    @Environment(AuthManager.self) var authManager
    
    private enum FocusedField {
        case email, password
    }
    
    @FocusState private var focusedField: FocusedField?
    
    @State private var email: String = ""
    @State private var password: String = ""
    
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
                        NavigationLink {
                            ResetPasswordScreen()
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
                    
                    VStack(spacing: 16) {
                        VStack {
                            Text("¿Todavía no tienes una cuenta?")
                                .fontWeight(.light)
                            NavigationLink {
                                SignUpForm()
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
        }
//        .border(.yellow, width: 1)z
        .frame(maxHeight: .infinity)
        .background(.customBlack)
//        .padding()
        .enableInjection()
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
    private func signInAction() {
        Task {
            await authManager.signIn(email: email, password: password)
        }
        
//        Task {
//            self.isLoading = true
//            self.errorMessage = nil
//            do {
//                try Validations.shared.isValidEmail(self.email)
//                try Validations.shared.isValidPassword(self.password)
//                try await auth.signIn(email: self.email, password: self.password)
//
//            } catch (let error as SignUpError) {
//                self.errorMessage = error.errorDescription
//            } catch {
//                print(error.localizedDescription)
//                self.errorMessage = error.localizedDescription
//            }
//            self.isLoading = false
//        }
    }
}

#Preview {
    
    @Previewable @State var email: String = ""
    @Previewable @State var password: String = ""
    @Previewable @State var authMode: AuthMode = .login
    SignInForm()
        .padding(18)
        .background(.customBlack)
//        .environment(AuthService())
        .environment(AuthManager(service: AuthService()))
}
