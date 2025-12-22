//
//  SignInForm.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 12/9/25.
//

import SwiftUI

struct SignInForm: View {
    @Environment(AuthService.self) var auth
    
    private enum FocusedField {
        case email, password
    }
    
    @FocusState private var focusedField: FocusedField?
    
    @Binding var email: String
    @Binding var password: String
    @Binding var isLoading: Bool
    @Binding var authMode: AuthMode
//    let action: () async -> Void
    
    @State private var errorMessage: String? = nil
    
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
//                Text("Iniciar sesión")
//                    .font(.system(size: 24, weight: .medium))
//                    .foregroundStyle(.white)
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
                }
                VStack {
                    Button {
                        signInAction()
                    } label: {
                        if isLoading {
                            ProgressView()
                                .tint(.dirtyWhite)
                        } else {
                            Text("Iniciar sesión")
                        }
                    }
                    .buttonStyle(.capsuleButton(.customRed))
                    .disabled(isLoading)
                 
                    VStack {
                        Text("¿Has olvidado tu contraseña?")
                        Button {
                            withAnimation(.easeIn) {
                                self.authMode = .resetPassword
                            }
                        } label: {
                            Text("Restablecer contraseña")
                                .underline()
                        }
                    }
                }
            }
        }
        .padding()
        .enableInjection()
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
    private func signInAction() {
        Task {
            self.isLoading = true
            self.errorMessage = nil
            do {
                try Validations.shared.isValidEmail(self.email)
                try Validations.shared.isValidPassword(self.password)
                try await auth.signIn(email: self.email, password: self.password)

            } catch (let error as SignUpError) {
                self.errorMessage = error.errorDescription
            } catch {
                print(error.localizedDescription)
                self.errorMessage = error.localizedDescription
            }
            self.isLoading = false
        }
    }
}

#Preview {
    
    @Previewable @State var email: String = ""
    @Previewable @State var password: String = ""
    @Previewable @State var authMode: AuthMode = .login
    SignInForm(email: $email, password: $password, isLoading: .constant(false), authMode: $authMode)
        .background(.customBlack)
        .environment(AuthService())
}
