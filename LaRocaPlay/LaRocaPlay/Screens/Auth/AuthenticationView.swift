//
//  AuthenticationView.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 17/8/25.
//

import SwiftUI
import Supabase
import RevenueCat

enum AuthMode {
    case login
    case signup
    case resetPassword
}

struct AuthenticationView: View {
    
    @Environment(AuthService.self) var auth

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var authMode: AuthMode = .login
    @State private var errorMessage: String? = nil
    @State private var isLoading = false
    
    var body: some View {
        VStack {
            Text("Todavía no has inicado sesión")
                .foregroundStyle(.dirtyWhite)
            
            Group {
                switch authMode {
                case .login:
                    SignInForm(
                        email: $email,
                        password: $password,
                        isLoading: $isLoading,
                        action: authAction
                    )
                case .signup:
                    SignUpForm(
                        email: $email,
                        password: $password,
                        confirmPassword: $confirmPassword,
                        isLoading: $isLoading,
                        action: authAction
                    )
                case .resetPassword:
                    Text("Reset password Screen")
                }
            }
            VStack(spacing: 24) {
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.orange)
                        .font(.system(size: 12))
                }
                
                VStack(spacing: 16) {
                    VStack {
                        Text(authMode == .login ? "¿Todavía no tienes una cuenta?" : "")
                            .fontWeight(.light)
                        Button {
                            withAnimation(.easeIn) {
                                authMode = authMode == .login ? .signup : .login
                            }
                        } label: {
                            Text(authMode == .login ? "Regístrate" : "Tengo cuenta")
                                .fontWeight(.bold)
                        }
                        .buttonStyle(.plain)
                        .disabled(isLoading)
                    }
                    .font(.system(size: 14))
                    .foregroundStyle(.dirtyWhite)
                }
            }
        }
        .frame(maxHeight: .infinity)
        .padding()
        .background(.customBlack)
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
    private func authAction() {
        // TODO: Añadir validación de campos antes de ejecutar la acción
        Task {
            do {
                isLoading = true
                if authMode == .login {
                    try await auth.signIn(email: email, password: password)
//                    if let user = auth.user {
//                        let rcInfo = try await Purchases.shared.logIn(user.id.uuidString)
//                        print(rcInfo.customerInfo)
//                        print(rcInfo.created)
//                    }
                    
                } else {
                    try await auth.signUp(email: email, password: password)
//                    if let user = auth.user {
//                        let rcInfo = try await Purchases.shared.logIn(user.id.uuidString)
//                        print(rcInfo.customerInfo)
//                        print(rcInfo.created)
//                    }
                }
            } catch(let error as Supabase.AuthError) {
                print(error)
                switch error.errorCode {
                case .invalidCredentials:
                    self.errorMessage = "Correo electrónico o contraseña inválidos"
                case .userAlreadyExists:
                    self.errorMessage = "Ya existe una cuenta con esa dirección de correo"
                default:
                    self.errorMessage = "Ocurrió un error inesperado. Por favor, intenta nuevamente más tarde."
                }
            } catch {
                print(error)
                print(error.localizedDescription)
                self.errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

#Preview {
    AuthenticationView()
        .environment(AuthService())
        .background(.customBlack)
}
