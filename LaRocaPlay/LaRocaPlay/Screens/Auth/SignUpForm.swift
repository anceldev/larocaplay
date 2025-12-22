//
//  SignUpForm.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 12/9/25.
//

import SwiftUI
import Supabase

struct SignUpForm: View {
    @Environment(AuthService.self) var auth
    private enum FocusedField {
        case email, password, confirmPassword
    }
    
    @FocusState private var focusedField: FocusedField?
    
    @Binding var email: String
    @Binding var password: String
    @Binding var confirmPassword: String
    @Binding var isLoading: Bool
    
    @State private var errorMessage: String? = nil
    
//    let action: () async -> Void
    
    var body: some View {
        VStack(spacing: 32) {
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

//            
//            Text("Registrarse")
//                .font(.system(size: 24, weight: .medium))
//                .foregroundStyle(.white)
//            
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
                if let errorMessage {
                    withAnimation(.easeIn) {
                        
                        Text(errorMessage)
                            .foregroundStyle(.orange)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 14))
                    }
                }
                Button {
                    signUpAction()
                } label: {
                    if isLoading {
                        ProgressView()
                            .tint(.dirtyWhite)
                    } else {
                        Text("Registrarse")
                    }
                }
                .buttonStyle(.capsuleButton(.customRed))
                .disabled(isLoading)
            }
        }
        .padding()
        .enableInjection()
    }
    
    private func signUpAction() {
        Task {
            self.isLoading = true
            self.errorMessage = nil
            do {
                try Validations.shared.isValidEmail(self.email)
                try checkPasswordsField()
                try await auth.signUp(email: self.email, password: self.password)

            } catch (let error as SignUpError) {
                self.errorMessage = error.errorDescription
            } catch (let error as Supabase.AuthError) {
                self.errorMessage = auth.supabaseAutherror(error: error)
            } catch {
                print(error.localizedDescription)
                self.errorMessage = error.localizedDescription
            }
            self.isLoading = false
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

#Preview {
    @Previewable @State var email = ""
    @Previewable @State var password = ""
    @Previewable @State var confirmPassword = ""
    
    SignUpForm(
        email: $email,
        password: $password,
        confirmPassword: $confirmPassword,
        isLoading: .constant(false),
    )
    .background(.customBlack)
    .environment(AuthService())
}
